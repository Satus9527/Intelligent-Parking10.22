@echo on

echo 正在配置Maven环境变量...

REM 配置环境变量的PowerShell命令
powershell -Command "
# 设置MAVEN_HOME系统变量
[System.Environment]::SetEnvironmentVariable('MAVEN_HOME', 'E:\apache-maven-3.8.8', [System.EnvironmentVariableTarget]::Machine)

# 获取当前Path变量
$currentPath = [System.Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)

# 检查Maven bin路径是否已在Path中
if (-not ($currentPath -like '*%MAVEN_HOME%\bin*' -or $currentPath -like '*E:\apache-maven-3.8.8\bin*')) {
    # 添加Maven bin路径到Path
    $newPath = $currentPath + ';%MAVEN_HOME%\bin'
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, [System.EnvironmentVariableTarget]::Machine)
    echo 'Maven环境变量配置成功！'
    echo '请重启命令提示符以应用新的环境变量。'
} else {
    echo 'Maven环境变量已存在！'
}
"

echo Maven环境变量配置脚本执行完成！
echo 请重启命令提示符后运行 'mvn -v' 验证安装。
pause