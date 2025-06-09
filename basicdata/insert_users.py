import json
import mysql.connector

# 加载 student_info.json 文件
with open('student_info.json', 'r', encoding='utf-8') as f:
    students = json.load(f)

# 连接 MySQL 数据库（请根据实际情况修改 host、user、password、database）
conn = mysql.connector.connect(
    host='localhost',
    user='your_username',
    password='your_password',
    database='your_database'
)
cursor = conn.cursor()

# 插入管理员账号
admin_username = 'admin'
admin_password = 'mg2357'
admin_role = 'admin'

cursor.execute("""
    INSERT INTO users (username, password, role, student_id)
    VALUES (%s, %s, %s, %s)
    ON DUPLICATE KEY UPDATE password=VALUES(password), role=VALUES(role)
""", (admin_username, admin_password, admin_role, None))

# 插入学生账号
for student in students:
    student_id = str(student['学号'])  # 转为字符串以匹配表定义
    name = student['姓名']
    username = name
    password = '123456'
    role = 'student'

    cursor.execute("""
        INSERT INTO users (username, password, role, student_id)
        VALUES (%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE password=VALUES(password), role=VALUES(role)
    """, (username, password, role, student_id))

# 提交更改并关闭连接
conn.commit()
cursor.close()
conn.close()

print("用户数据已成功插入 users 表。")
