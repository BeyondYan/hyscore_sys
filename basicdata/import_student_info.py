import pymysql
import json

# 汉字字段到英文列名的映射
field_mapping = {
    "学号": "student_id",
    "姓名": "name",
    "性别": "gender",
    "所属学院": "college"
}

# JSON 文件路径
json_file = "student_data.json"  # 请确保该文件在当前目录或给出绝对路径

# 数据库连接配置
db_config = {
    "host": "localhost",
    "user": "your_username",       # 替换为你的用户名
    "password": "your_password",   # 替换为你的密码
    "database": "hysys",
    "charset": "utf8mb4"
}

def load_and_insert_data():
    # 连接数据库
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()

    # 加载 JSON 文件
    with open(json_file, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    # 对每一条数据进行字段名映射
    for item in raw_data:
        translated = {field_mapping[k]: v for k, v in item.items() if k in field_mapping}

        # 构建插入语句
        sql = """
            INSERT INTO student_info (student_id, name, gender, college)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE name=VALUES(name), gender=VALUES(gender), college=VALUES(college)
        """
        values = (
            translated["student_id"],
            translated["name"],
            translated["gender"],
            translated["college"]
        )

        cursor.execute(sql, values)

    # 提交事务
    conn.commit()
    cursor.close()
    conn.close()
    print("数据导入完成。")

if __name__ == "__main__":
    load_and_insert_data()
