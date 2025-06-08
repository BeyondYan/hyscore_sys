/*
完整 JSP + JDBC 分页查询系统（含权限控制）
使用环境：Tomcat + JSP + MySQL + JDBC
*/

// ========== 1. 数据库结构 SQL ===========
-- 学生基本信息表
CREATE TABLE student_info (
    student_id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(50),
    gender VARCHAR(10),
    college VARCHAR(100)
);

-- 本学期成绩表
CREATE TABLE current_scores (
    student_id VARCHAR(20),
    subject_name VARCHAR(50),
    score FLOAT,
    FOREIGN KEY (student_id) REFERENCES student_info(student_id)
);

-- 科目信息表
CREATE TABLE subject_info (
    subject_name VARCHAR(50) PRIMARY KEY,
    description TEXT,
    credit INT,
    teacher VARCHAR(50)
);

-- 用户表（管理员和学生）
CREATE TABLE user (
    username VARCHAR(20) PRIMARY KEY,
    password VARCHAR(50),
    role VARCHAR(10)  -- 'admin' or 'student'
);


// ========== 2. login.jsp ===========
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<html>
<body>
<form action="LoginServlet" method="post">
  用户名: <input type="text" name="username"><br>
  密码: <input type="password" name="password"><br>
  <input type="submit" value="登录">
</form>
</body>
</html>


// ========== 3. LoginServlet.java ===========
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT role FROM user WHERE username=? AND password=?");
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String role = rs.getString("role");
                request.getSession().setAttribute("username", username);
                request.getSession().setAttribute("role", role);
                response.sendRedirect("ScoreList.jsp?page=1");
            } else {
                response.getWriter().println("登录失败");
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
}


// ========== 4. ScoreList.jsp ===========
<%@ page import="java.sql.*" %>
<%
String username = (String) session.getAttribute("username");
String role = (String) session.getAttribute("role");
int page = Integer.parseInt(request.getParameter("page"));
int pageSize = 5;
int offset = (page - 1) * pageSize;

Connection conn = DBUtil.getConnection();
PreparedStatement ps;
if ("admin".equals(role)) {
    ps = conn.prepareStatement("SELECT s.student_id, s.name, c.subject_name, c.score FROM student_info s JOIN current_scores c ON s.student_id = c.student_id LIMIT ?, ?");
    ps.setInt(1, offset);
    ps.setInt(2, pageSize);
} else {
    ps = conn.prepareStatement("SELECT s.student_id, s.name, c.subject_name, c.score FROM student_info s JOIN current_scores c ON s.student_id = c.student_id WHERE s.student_id = ? LIMIT ?, ?");
    ps.setString(1, username);
    ps.setInt(2, offset);
    ps.setInt(3, pageSize);
}
ResultSet rs = ps.executeQuery();
%>
<table border="1">
<tr><th>学号</th><th>姓名</th><th>科目</th><th>成绩</th></tr>
<%
while (rs.next()) {
%>
<tr>
  <td><%= rs.getString("student_id") %></td>
  <td><%= rs.getString("name") %></td>
  <td><%= rs.getString("subject_name") %></td>
  <td><%= rs.getFloat("score") %></td>
</tr>
<% } %>
</table>
<% if (page > 1) { %>
  <a href="ScoreList.jsp?page=<%= page - 1 %>">上一页</a>
<% } %>
<% if (rs.last() && rs.getRow() == pageSize) { %>
  <a href="ScoreList.jsp?page=<%= page + 1 %>">下一页</a>
<% } %>


// ========== 5. DBUtil.java ===========
public class DBUtil {
    public static Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/yourdb?useSSL=false&serverTimezone=UTC", "root", "password");
    }
}


// ========== 6. AdminPanel.jsp ===========
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
if (!"admin".equals(session.getAttribute("role"))) {
    response.sendRedirect("login.jsp");
    return;
}
%>
<h2>管理员操作界面</h2>
<form action="AddScoreServlet" method="post">
  学号: <input type="text" name="student_id">
  科目: <input type="text" name="subject_name">
  成绩: <input type="text" name="score">
  <input type="submit" value="添加成绩">
</form>

<form action="DeleteScoreServlet" method="post">
  学号: <input type="text" name="student_id">
  科目: <input type="text" name="subject_name">
  <input type="submit" value="删除成绩">
</form>

<form action="UpdateScoreServlet" method="post">
  学号: <input type="text" name="student_id">
  科目: <input type="text" name="subject_name">
  新成绩: <input type="text" name="score">
  <input type="submit" value="更新成绩">
</form>


// ========== 7. AddScoreServlet.java ===========
@WebServlet("/AddScoreServlet")
public class AddScoreServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("student_id");
        String subject = request.getParameter("subject_name");
        float score = Float.parseFloat(request.getParameter("score"));
        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("INSERT INTO current_scores (student_id, subject_name, score) VALUES (?, ?, ?)");
            ps.setString(1, id);
            ps.setString(2, subject);
            ps.setFloat(3, score);
            ps.executeUpdate();
            response.sendRedirect("AdminPanel.jsp");
        } catch (Exception e) { e.printStackTrace(); }
    }
}


// ========== 8. DeleteScoreServlet.java ===========
@WebServlet("/DeleteScoreServlet")
public class DeleteScoreServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("student_id");
        String subject = request.getParameter("subject_name");
        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM current_scores WHERE student_id=? AND subject_name=?");
            ps.setString(1, id);
            ps.setString(2, subject);
            ps.executeUpdate();
            response.sendRedirect("AdminPanel.jsp");
        } catch (Exception e) { e.printStackTrace(); }
    }
}


// ========== 9. UpdateScoreServlet.java ===========
@WebServlet("/UpdateScoreServlet")
public class UpdateScoreServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = request.getParameter("student_id");
        String subject = request.getParameter("subject_name");
        float score = Float.parseFloat(request.getParameter("score"));
        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("UPDATE current_scores SET score=? WHERE student_id=? AND subject_name=?");
            ps.setFloat(1, score);
            ps.setString(2, id);
            ps.setString(3, subject);
            ps.executeUpdate();
            response.sendRedirect("AdminPanel.jsp");
        } catch (Exception e) { e.printStackTrace(); }
    }
}
