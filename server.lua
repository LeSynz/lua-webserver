local socket = require("socket")
local json = require("dkjson")

local server = assert(socket.bind("localhost", 3000))

local TODOS_FILE = "todos.json"

-- load the todos from json
local function load_todos()
    local file = io.open(TODOS_FILE, "r")
    if not file then return {} end
    local content = file:read("*a")
    file:close()
    local todos, _, err = json.decode(content)
    if err then
        print("Error decoding JSON:", err)
        return {}
    end
    return todos or {}
end
-- save the todos to json
local function save_todos(todos)
    local file = io.open(TODOS_FILE, "w+")
    if not file then
        print("Error opening file for writing:", TODOS_FILE)
        return
    end
    local content = json.encode(todos, { indent = true })
    file:write(content)
    file:close()
end

-- server stuff idk
print("Server started on port 3000")

while true do
    local client = server:accept()
    client:settimeout(1)

    local request = ""
    while true do
        local line, err = client:receive()
        if err or line == "" then break end
        request = request .. line .. "\n"
    end
    print("Received request:\n" .. request)
    -- basic parsing
    local method, path = request:match("^(%w+)%s(/%S*)")
    local content_length = tonumber(request:match("[Cc]ontent%-[Ll]ength:%s*(%d+)")) or 0
    local body = ""

    if content_length > 0 then
        body = client:receive(content_length) or ""
        print("Received body:\n" .. body)
    end

    -- basic routing
    if method == "GET" and path == "/todos" then
        local todos = load_todos()
        local response_body = json.encode(todos, { indent = true })
        local response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: " .. #response_body .. "\r\n\r\n" .. response_body
        client:send(response)
    elseif method == "POST" and path == "/todos" then
        local todos = load_todos()
        local new_todo, _, err = json.decode(body)
        if err or type(new_todo) ~= "table" or not new_todo.text then
            local response = "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\n\r\n"
            client:send(response)
        else
            new_todo.id = (#todos > 0) and (todos[#todos].id + 1) or 1
            new_todo.completed = false
            table.insert(todos, new_todo)
            save_todos(todos)
            local response_body = json.encode(new_todo, { indent = true })
            local response = "HTTP/1.1 201 Created\r\nContent-Type: application/json\r\nContent-Length: " .. #response_body .. "\r\n\r\n" .. response_body
            client:send(response)
        end
    elseif method == "PUT" and path == "/todos" then
        local todos = load_todos()
        local updated_todo, _, err = json.decode(body)
        if err or type(updated_todo) ~= "table" or not updated_todo.id then
            local response = "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\n\r\n"
            client:send(response)
        else
            local found = false
            for i, todo in ipairs(todos) do
                if todo.id == updated_todo.id then
                    todos[i] = updated_todo
                    found = true
                    break
                end
            end
            if found then
                save_todos(todos)
                local response_body = json.encode(updated_todo, { indent = true })
                local response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: " .. #response_body .. "\r\n\r\n" .. response_body
                client:send(response)
            else
                local response = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"
                client:send(response)
            end
        end
    elseif method == "DELETE" and path == "/todos" then
        local todos = load_todos()
        local id = tonumber(body:match('"id"%s*:%s*(%d+)'))
        if not id then
            local response = "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\n\r\n"
            client:send(response)
        else
            local index = nil
            for i, todo in ipairs(todos) do
                if todo.id == id then
                    index = i
                    break
                end
            end
            if index then
                table.remove(todos, index)
                save_todos(todos)
                local response = "HTTP/1.1 200 OK\r\nContent-Length: 0\r\n\r\n"
                client:send(response)
            else
                local response = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"
                client:send(response)
            end
        end
    else
        local response = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"
        client:send(response)
    end
    client:close()
end