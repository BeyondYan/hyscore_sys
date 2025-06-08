# hyscore_sys
A easy demo for database searching  by java web
```
 -- 1. 基本信息表
CREATE TABLE student_info (
    student_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    gender VARCHAR(10),
    college VARCHAR(100)
);

 -- 2. 本学期成绩表
CREATE TABLE semester_scores (
    student_id VARCHAR(20),
    subject_name VARCHAR(50),
    score FLOAT,
    FOREIGN KEY (student_id) REFERENCES student_info(student_id)
);

 -- 3. 科目信息表
CREATE TABLE subject_info (
    subject_name VARCHAR(50) PRIMARY KEY,
    subject_intro TEXT,
    credit FLOAT,
    teacher VARCHAR(50)
);

 -- 4. 用户表（登录权限）
CREATE TABLE users (
    username VARCHAR(20) PRIMARY KEY,
    password VARCHAR(50),
    role ENUM('admin', 'student'),
    student_id VARCHAR(20),  -- 若为学生，关联 student_info
    FOREIGN KEY (student_id) REFERENCES student_info(student_id)
);
```
