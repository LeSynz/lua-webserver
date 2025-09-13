# Lua Webserver

A simple webserver built with Lua as part of my journey to learn new languages by creating basic todo webservers in each.

## Goals

- Learn Lua fundamentals
- Build a minimal webserver
- Implement basic todo CRUD functionality

## Features

- Serve HTTP requests
- Add, view, update, and delete todo items
- Lightweight and easy to understand

## Dependencies

- [LuaSocket](https://lunarmodules.github.io/luasocket/) (`luarocks install luasocket`)
- [dkjson](https://github.com/LuaDist/dkjson) (`luarocks install dkjson`)

Install dependencies using [LuaRocks](https://luarocks.org/):

```sh
luarocks install luasocket
luarocks install dkjson
```

## Getting Started

1. **Install Lua**  
    Download and install Lua from [lua.org](https://www.lua.org/).

2. **Clone this repository**  
    ```sh
    git clone https://github.com/yourusername/lua-webserver.git
    cd lua-webserver
    ```

3. **Install dependencies**  
    See [Dependencies](#dependencies) above.

4. **Run the server**  
    ```sh
    lua server.lua
    ```

5. **Open your browser**  
    Visit `http://localhost:3000`

## Testing with curl

- **Get all todos**
    ```sh
    curl http://localhost:3000/todos
    ```

- **Add a todo**
    ```sh
    curl -X POST -H "Content-Type: application/json" -d "{\"text\":\"Buy milk\"}" http://localhost:3000/todos
    ```

- **Update a todo**
    ```sh
    curl -X PUT -H "Content-Type: application/json" -d "{\"id\":1,\"text\":\"Buy bread\",\"completed\":true}" http://localhost:3000/todos
    ```

- **Delete a todo**
    ```sh
    curl -X DELETE -H "Content-Type: application/json" -d "{\"id\":1}" http://localhost:3000/todos
    ```

## Why Lua?

Lua is lightweight, embeddable, and widely used in game development and scripting. This project helps explore its capabilities for web development.

## License

MIT