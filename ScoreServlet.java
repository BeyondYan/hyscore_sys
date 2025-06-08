@WebServlet("/score")
public class ScoreServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String action = req.getParameter("action");
        if ("update".equals(action)) {
            String id = req.getParameter("student_id");
            String subject = req.getParameter("subject_name");
            float score = Float.parseFloat(req.getParameter("score"));
            try (Connection conn = DBUtil.getConnection()) {
                PreparedStatement ps = conn.prepareStatement(
                    "UPDATE semester_scores SET score=? WHERE student_id=? AND subject_name=?");
                ps.setFloat(1, score);
                ps.setString(2, id);
                ps.setString(3, subject);
                ps.executeUpdate();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            resp.sendRedirect("view_scores.jsp");
        }
    }
}
