<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    if (username == null || role == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>系统首页</title>
    <style>
        body {
            background-color: #f4f6f8;
            font-family: "Segoe UI", sans-serif;
        }
        .container {
            max-width: 600px;
            margin: 60px auto;
            padding: 30px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h2, h3 {
            text-align: center;
            color: #333;
        }
        ul {
            list-style: none;
            padding: 0;
        }
        li {
            margin: 15px 0;
            text-align: center;
        }
        a {
            text-decoration: none;
            color: #007bff;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
        .footer {
            text-align: center;
            margin-top: 30px;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>欢迎，<%= username %>！</h2>
    <hr/>

    <% if ("admin".equals(role)) { %>
        <h3>管理员功能区</h3>
        <ul>
            <li><a href="view_all_scores.jsp">查看所有学生成绩</a></li>
            <li><a href="add_score.jsp">添加学生成绩</a></li>
            <li><a href="manage_students.jsp">管理学生信息</a></li>
        </ul>
    <% } else if ("student".equals(role)) { %>
        <h3>学生功能区</h3>
        <ul>
            <li><a href="view_my_score.jsp">查看我的成绩</a></li>
        </ul>
    <% } else { %>
        <p>未知身份，无法加载功能</p>
    <% } %>

    <div class="footer">
        <a href="change_password.jsp">修改密码</a> |
        <a href="logout.jsp">退出登录</a>
    </div>
</div>
</body>
</html>
