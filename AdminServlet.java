// 如果没有包，就不要写 package；否则写 package admin;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class AdminServlet extends HttpServlet {

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html;charset=UTF-8");

        String action = req.getParameter("action");  // add / update / delete
        String studentId = req.getParameter("student_id");
        String subject = req.getParameter("subject");
        String scoreStr = req.getParameter("score");

        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = null;

            switch (action) {
                case "add":
                    ps = conn.prepareStatement("INSERT INTO scores (student_id, subject, score) VALUES (?, ?, ?)");
                    ps.setString(1, studentId);
                    ps.setString(2, subject);
                    ps.setDouble(3, Double.parseDouble(scoreStr));
                    break;

                case "update":
                    ps = conn.prepareStatement("UPDATE scores SET score=? WHERE student_id=? AND subject=?");
                    ps.setDouble(1, Double.parseDouble(scoreStr));
                    ps.setString(2, studentId);
                    ps.setString(3, subject);
                    break;

                case "delete":
                    ps = conn.prepareStatement("DELETE FROM scores WHERE student_id=? AND subject=?");
                    ps.setString(1, studentId);
                    ps.setString(2, subject);
                    break;
            }

            if (ps != null) ps.executeUpdate();
            resp.sendRedirect("admin_panel.jsp");  // 回到管理面板

        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("操作失败: " + e.getMessage());
        }
    }
}
