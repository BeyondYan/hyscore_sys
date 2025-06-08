import pymysql
import json

# 汉字字段名到英文字段名的映射
field_mapping = {
    "学号": "student_id",
    "科目": "subject_name",
    "成绩": "score"
    # "姓名" 会被忽略，因为该字段不是 semester_scores 表的一部分
}

# JSON 文件路径（自行调整）
json_file = "semester_scores.json"

# 数据库连接配置（根据你的实际信息修改）
db_config = {
    "host": "localhost",
    "user": "your_username",       # 替换为你的 MySQL 用户名
    "password": "your_password",   # 替换为你的 MySQL 密码
    "database": "hysys",
    "charset": "utf8mb4"
}

def load_and_insert_scores():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()

    # 加载 JSON 文件
    with open(json_file, "r", encoding="utf-8") as f:
        raw_data = json.load(f)

    for item in raw_data:
        # 字段映射（跳过姓名字段）
        translated = {field_mapping[k]: v for k, v in item.items() if k in field_mapping}

        sql = """
            INSERT INTO semester_scores (student_id, subject_name, score)
            VALUES (%s, %s, %s)
        """
        values = (
            str(translated["student_id"]),
            translated["subject_name"],
            float(translated["score"])
        )

        try:
            cursor.execute(sql, values)
        except pymysql.err.IntegrityError as e:
            print(f"插入失败：{values}，原因：{e}")

    conn.commit()
    cursor.close()
    conn.close()
    print("成绩导入完成。")

if __name__ == "__main__":
    load_and_insert_scores()
