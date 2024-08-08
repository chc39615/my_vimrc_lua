---@class myutil.providers
M = {}

if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    M.plugin_path = vim.fn.stdpath("data") .. "\\pynvim"
    M.venv_path = M.plugin_path .. "\\venv"
    M.venv_python = M.venv_path .. "\\Scripts\\python"
else
    M.plugin_path = vim.fn.stdpath("data") .. "/pynvim"
    M.venv_path = M.plugin_path .. "/venv"
    M.venv_python = M.venv_path .. "/bin/python"
end
M.freeze_file = M.plugin_path .. '/requirements.txt'

function M.check_python()
    if vim.fn.executable("python") == 0 then
        print("Python is no installed or not found in PATH.")
        return false
    end
    return true
end

function M.check_pynvim()
    if vim.fn.filereadable(M.freeze_file) == 1 then
        local content = vim.fn.readfile(M.freeze_file)
        local contains_pynvim = false
        local contains_typing_extensions = false

        for _, line in ipairs(content) do
            if line:match("pynvim") then
                contains_pynvim = true
            end
            if line:match("typing%-extensions") then
                contains_typing_extensions = true
            end
        end

        if contains_pynvim and contains_typing_extensions then
            return true
        else
            print("pynvim and/or typing-extensions are not installed.")
            return false
        end
    else
        print("pip_freeze.txt file does not exist.")
        return false
    end
end

function M.setup_pynvim()
    if not M.check_python() then
        return
    end

    -- Create the plugin directory if it doesn't exist
    vim.fn.mkdir(M.plugin_path, "p")

    -- Create the virtual environment
    local create_venv_cmd = "python -m venv " .. M.venv_path
    print(create_venv_cmd)
    local create_venv_result = vim.fn.system(create_venv_cmd)
    if vim.v.shell_error ~= 0 then
        print("Error creating virtual environment: " .. (create_venv_result or "unknown error"))
        return
    end

    -- Install pynvim in the virtual environment
    local install_pynvim_cmd = M.venv_python .. " -m pip install pynvim typing-extensions"
    print(install_pynvim_cmd)
    local install_pynvim_result = vim.fn.system(install_pynvim_cmd)
    if vim.v.shell_error ~= 0 then
        print("Error installing pynvim: " .. (install_pynvim_result or "unknown error"))
    end

    -- Save the output of pip freeze to a text file
    local pip_freeze_cmd = M.venv_python .. ' -m pip freeze > ' .. M.freeze_file
    local pip_freeze_result = vim.fn.system(pip_freeze_cmd)
    if vim.v.shell_error ~= 0 then
        print("Error freezing pip packages: " .. (pip_freeze_result or "unknown error"))
        return
    end

    print("Virtual environment 'pynvim' created and pynvim installed successfully.")
end

return M
