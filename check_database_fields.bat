@echo off
chcp 65001 >nul
echo ========================================
echo 检查数据库字段一致性
echo ========================================
echo.

echo 正在连接数据库检查字段...
echo.

mysql -uroot -p123 parking_db -e "
-- 检查 parking_space 表中的字段名
SELECT 
    'parking_space表字段:' AS info;
SELECT 
    COLUMN_NAME AS 字段名,
    COLUMN_TYPE AS 类型,
    COLUMN_COMMENT AS 说明
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'parking_db'
  AND TABLE_NAME = 'parking_space'
  AND (COLUMN_NAME LIKE '%parking%' OR COLUMN_NAME LIKE '%lot%')
ORDER BY ORDINAL_POSITION;

SELECT '' AS '';
SELECT '=== 检查车位表实际使用的字段 ===' AS info;
SELECT 
    CASE 
        WHEN COUNT(CASE WHEN COLUMN_NAME = 'parking_id' THEN 1 END) > 0 THEN '✓ 有 parking_id'
        ELSE '✗ 无 parking_id'
    END AS parking_id_field,
    CASE 
        WHEN COUNT(CASE WHEN COLUMN_NAME = 'parking_lot_id' THEN 1 END) > 0 THEN '✓ 有 parking_lot_id'
        ELSE '✗ 无 parking_lot_id'
    END AS parking_lot_id_field,
    CASE 
        WHEN COUNT(CASE WHEN COLUMN_NAME = 'lot_id' THEN 1 END) > 0 THEN '✓ 有 lot_id'
        ELSE '✗ 无 lot_id'
    END AS lot_id_field
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'parking_db'
  AND TABLE_NAME = 'parking_space';

SELECT '' AS '';
SELECT '=== 车位数据样例（查看实际字段） ===' AS info;
SELECT * FROM parking_space LIMIT 3;
"

echo.
echo 检查完成！
pause

