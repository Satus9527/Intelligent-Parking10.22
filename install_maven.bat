@echo on

REM 创建临时目录在当前项目中
mkdir maven_temp 2>nul
cd maven_temp

echo 开始下载Maven 3.8.8...
REM 下载Maven 3.8.8
powershell -Command "
Write-Host '正在下载Maven...'
Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.8.8/binaries/apache-maven-3.8.8-bin.zip' -OutFile 'maven.zip' -UseBasicParsing
Write-Host '下载完成，正在解压...'
"

REM 检查下载是否成功
if exist maven.zip (
    echo Maven安装包下载成功！
    
    REM 解压Maven
    powershell -Command "Expand-Archive -Path 'maven.zip' -DestinationPath '.' -Force"
    
    REM 检查解压是否成功
    if exist apache-maven-3.8.8 (
        echo Maven解压成功！
        
        REM 复制到最终安装目录
        echo 正在复制到安装目录...
        mkdir E:\apache-maven-3.8.8 2>nul
        xcopy apache-maven-3.8.8 E:\apache-maven-3.8.8 /E /I /H /Y
        
        echo Maven文件复制完成！
        
        REM 创建本地仓库目录
        echo 创建Maven本地仓库...
        mkdir E:\maven-repo 2>nul
        
        REM 配置Maven settings.xml
        echo 配置Maven settings.xml...
        if exist E:\apache-maven-3.8.8\conf\settings.xml (
            copy E:\apache-maven-3.8.8\conf\settings.xml E:\apache-maven-3.8.8\conf\settings.xml.bak
            
            powershell -Command "
            Write-Host '正在更新settings.xml配置...'
            $settingsFile = 'E:\apache-maven-3.8.8\conf\settings.xml';
            $content = Get-Content -Path $settingsFile -Raw;
            
            # 设置本地仓库
            $localRepoXml = '<localRepository>E:\\maven-repo</localRepository>';
            if ($content -match '<localRepository>.*?</localRepository>') {
                $content = $content -replace '<localRepository>.*?</localRepository>', $localRepoXml;
            } else {
                $content = $content -replace '<settings>', '<settings>\r\n  ' + $localRepoXml;
            }
            
            # 添加阿里云镜像
            $mirrorXml = @"
  <mirror>
    <id>aliyunmaven</id>
    <mirrorOf>*</mirrorOf>
    <name>阿里云公共仓库</name>
    <url>https://maven.aliyun.com/repository/public</url>
  </mirror>
"@;
            
            if (-not ($content -match '<mirror>.*?aliyunmaven.*?</mirror>')) {
                if ($content -match '<mirrors>') {
                    $content = $content -replace '<mirrors>', '<mirrors>\r\n' + $mirrorXml;
                } else {
                    $content += '\r\n  <mirrors>\r\n' + $mirrorXml + '\r\n  </mirrors>';
                }
            }
            
            Set-Content -Path $settingsFile -Value $content -Encoding UTF8;
            Write-Host 'settings.xml配置更新完成！'
            "
            
            echo Maven配置完成！
            echo.
            echo ============================
            echo Maven安装完成！
            echo 安装路径：E:\apache-maven-3.8.8
            echo 本地仓库：E:\maven-repo
            echo ============================
            echo.
            echo 请手动配置环境变量：
            echo 1. 设置MAVEN_HOME=E:\apache-maven-3.8.8
            echo 2. 将%%MAVEN_HOME%%\bin添加到Path环境变量
            echo 3. 打开新的命令提示符，运行 'mvn -v' 验证安装
        } else {
            echo 错误：找不到settings.xml文件！
        }
    ) else {
        echo 错误：Maven解压失败！
    }
) else {
    echo 错误：Maven安装包下载失败！
}

REM 清理临时文件
cd ..
rd /s /q maven_temp 2>nul

echo 安装脚本执行完成！
pause