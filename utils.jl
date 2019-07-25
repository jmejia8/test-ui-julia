function check_home_directory(myhomepath, projectpath)
    if !isdir(myhomepath)
        try
            mkdir(myhomepath)
            mkdir(projectpath)
        catch
            return false
        end
    end

    return true
end