<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="utils.DBUtil" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String studentId = (String) session.getAttribute("student_id");
    if (username == null || role == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String keyword = request.getParameter("keyword");
    String sql = "";
    Connection conn = DBUtil.getConnection();
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<html>
<head>
    <meta charset="UTF-8">
    <title>主页 - 信息系统</title>
    <style>
        body { font-family: Arial; background: #f0f2f5; padding: 20px; }
        .container { background: #fff; padding: 20px; border-radius: 8px; width: 90%; margin: auto; }
        h2 { text-align: center; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { padding: 10px; border: 1px solid #ccc; text-align: center; }
        form { margin-top: 20px; text-align: center; }
        input[type="text"] { padding: 5px; width: 200px; }
        input[type="submit"] { padding: 5px 10px; }
        .admin-ops a { margin: 0 5px; color: blue; text-decoration: none; }
    </style>
</head>
<body>
<div class="container">
    <h2>欢迎，<%= username %>（<%= role %>）</h2>
    <form method="post">
        <% if ("student".equals(role)) { %>
            按科目查询成绩：
            <input type="text" name="keyword" placeholder="如 数学" />
            <input type="submit" value="搜索" />
        <% } else if ("admin".equals(role)) { %>
            按学号或科目查询成绩：
            <input type="text" name="keyword" placeholder="学号 或 科目名" />
            <input type="submit" value="搜索" />
        <% } %>
    </form>

    <table>
        <tr>
            <th>ID</th>
            <th>学号</th>
            <th>姓名</th>
            <th>科目</th>
            <th>成绩</th>
            <% if ("admin".equals(role)) { %><th>操作</th><% } %>
        </tr>
        <%
            if ("student".equals(role)) {
                if (keyword == null || keyword.trim().equals("")) {
                    sql = "SELECT * FROM scores WHERE student_id=?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, studentId);
                } else {
                    sql = "SELECT * FROM scores WHERE student_id=? AND subject_name LIKE ?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, studentId);
                    ps.setString(2, "%" + keyword + "%");
                }
            } else if ("admin".equals(role)) {
                if (keyword == null || keyword.trim().equals("")) {
                    sql = "SELECT * FROM scores";
                    ps = conn.prepareStatement(sql);
                } else {
                    sql = "SELECT * FROM scores WHERE student_id=? OR subject_name LIKE ?";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, keyword);
                    ps.setString(2, "%" + keyword + "%");
                }
            }

            rs = ps.executeQuery();
            while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("id") %></td>
            <td><%= rs.getString("student_id") %></td>
            <td><%= rs.getString("student_name") %></td>
            <td><%= rs.getString("subject_name") %></td>
            <td><%= rs.getFloat("score") %></td>
            <% if ("admin".equals(role)) { %>
                <td class="admin-ops">
                    <a href="edit_score.jsp?id=<%= rs.getInt("id") %>">修改</a>
                    <a href="delete_score.jsp?id=<%= rs.getInt("id") %>" onclick="return confirm('确定删除？')">删除</a>
                </td>
            <% } %>
        </tr>
        <% } %>
    </table>
    <% if (ps != null) ps.close(); if (conn != null) conn.close(); %>
</div>
</body>
</html>
