<%@ page import="java.util.*,java.sql.*" %>
<%
    String role = (String) session.getAttribute("role");
    String studentId = (String) session.getAttribute("student_id");
    int pageSize = 5;
    int page = request.getParameter("page") == null ? 1 : Integer.parseInt(request.getParameter("page"));
    int offset = (page - 1) * pageSize;

    Connection conn = DBUtil.getConnection();
    PreparedStatement ps;
    if ("admin".equals(role)) {
        ps = conn.prepareStatement("SELECT * FROM semester_scores LIMIT ?,?");
        ps.setInt(1, offset);
        ps.setInt(2, pageSize);
    } else {
        ps = conn.prepareStatement("SELECT * FROM semester_scores WHERE student_id=? LIMIT ?,?");
        ps.setString(1, studentId);
        ps.setInt(2, offset);
        ps.setInt(3, pageSize);
    }

    ResultSet rs = ps.executeQuery();
%>
<h3>成绩列表</h3>
<table border="1">
    <tr><th>学号</th><th>科目</th><th>成绩</th>
    <% if ("admin".equals(role)) { %><th>操作</th><% } %>
    </tr>
<%
    while (rs.next()) {
%>
<tr>
    <td><%= rs.getString("student_id") %></td>
    <td><%= rs.getString("subject_name") %></td>
    <td><%= rs.getFloat("score") %></td>
    <% if ("admin".equals(role)) { %>
    <td>
        <a href="edit_score.jsp?student_id=<%=rs.getString("student_id")%>&subject=<%=rs.getString("subject_name")%>">编辑</a>
    </td>
    <% } %>
</tr>
<% } %>
</table>

<%
    // 分页按钮
    ps = conn.prepareStatement("SELECT COUNT(*) FROM semester_scores" + 
        ("student".equals(role) ? " WHERE student_id=?" : ""));
    if ("student".equals(role)) ps.setString(1, studentId);
    ResultSet countRs = ps.executeQuery();
    countRs.next();
    int total = countRs.getInt(1);
    int totalPages = (int) Math.ceil(total * 1.0 / pageSize);
%>
<p>
    当前页: <%= page %> / 共 <%= totalPages %> 页
    <% for (int i = 1; i <= totalPages; i++) { %>
        <a href="view_scores.jsp?page=<%=i%>"><%= i %></a>
    <% } %>
</p>
