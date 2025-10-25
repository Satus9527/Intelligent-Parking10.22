@echo on

echo 检查Maven安装状态...

REM 使用完整路径运行Maven版本检查
E:\apache-maven-3.8.8\bin\mvn -v

if %errorlevel% equ 0 (
    echo ============================
    echo Maven安装成功！
    echo 安装路径：E:\apache-maven-3.8.8
    echo ============================
    echo.
    echo 请按照以下步骤手动配置环境变量：
    echo 1. 右键点击"此电脑" - "属性" - "高级系统设置" - "环境变量"
    echo 2. 在"系统变量"中点击"新建"
    echo    - 变量名：MAVEN_HOME
    echo    - 变量值：E:\apache-maven-3.8.8
    echo 3. 找到"Path"系统变量，点击"编辑"
    echo 4. 点击"新建"，添加：%%MAVEN_HOME%%\bin
    echo 5. 点击"确定"保存所有设置
    echo 6. 重启命令提示符后，直接运行 'mvn -v' 验证
) else (
    echo Maven安装失败！请重新运行安装脚本。
)

pause