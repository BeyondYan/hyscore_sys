<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<html>
<body>
<h2>登录系统</h2>
<form action="login" method="post">
    用户名：<input type="text" name="username" /><br/>
    密码：<input type="password" name="password" /><br/>
    <input type="submit" value="登录" />
</form>
<% if (request.getAttribute("msg") != null) { %>
    <p style="color:red"><%= request.getAttribute("msg") %></p>
<% } %>
</body>
</html>
