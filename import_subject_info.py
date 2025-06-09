import pymysql
import json

# 汉字字段映射为数据库列名
field_mapping = {
    "科目": "subject_name",
    "科目代码": "subject_intro",
    "学分": "credit",
    "授课老师": "teacher"
}

# JSON 文件路径
json_file = "subject_info.json"

# 数据库连接配置（按实际情况修改）
db_config = {
    "host": "localhost",
    "user": "your_username",       # 替换为你的用户名
    "password": "your_password",   # 替换为你的密码
    "database": "hysys",
    "charset": "utf8mb4"
}

def load_and_insert_subjects():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()

    with open(json_file, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    for item in raw_data:
        translated = {field_mapping[k]: v for k, v in item.items() if k in field_mapping}

        sql = """
            INSERT INTO subject_info (subject_name, subject_intro, credit, teacher)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE subject_intro=VALUES(subject_intro),
                                    credit=VALUES(credit),
                                    teacher=VALUES(teacher)
        """
        values = (
            translated["subject_name"],
            translated["subject_intro"],
            float(translated["credit"]),
            translated["teacher"]
        )

        cursor.execute(sql, values)

    conn.commit()
    cursor.close()
    conn.close()
    print("科目信息导入完成。")

if __name__ == "__main__":
    load_and_insert_subjects()
