package uz.pdp.mini_blok_with_jakarta.servlet.user;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import uz.pdp.mini_blok_with_jakarta.dao.AuthUserDao;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;

import java.io.IOException;
import static uz.pdp.mini_blok_with_jakarta.utils.JsonUtils.q;
import java.util.List;
@WebServlet(name = "UserSearchServlet",urlPatterns = "/user/search")
public class UserSearchServlet extends HttpServlet {
    private final AuthUserDao authUserDao = new AuthUserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String query = req.getParameter("q");
        resp.setContentType("application/json;charset=UTF-8");
        if(query==null || query.trim().isEmpty()){
            resp.getWriter().write("[]");
            return;
        }
        String term = query.trim();
        if (term.length() > 30) term = term.substring(0, 30);
        term = term.replace("%", "").replace("\\", "");
        List<AuthUser> users =authUserDao.searchByusernamePrefix(term,10);

        StringBuilder json = new StringBuilder("[");
        for (int i=0; i<users.size(); i++){
            AuthUser u = users.get(i);
            json.append("{\"id\": ").append(u.getId())
                .append(", \"username\": ").append(q(u.getUsername()))
                .append(", \"fullName\": ").append(q(u.getFullName()))
                .append(", \"avatar\": ").append(q(u.getAvatarUrl() != null ? u.getAvatarUrl() : ""))
                .append(", \"verified\": ").append(u.isVerifiedUser())
                .append("}");
            if(i< users.size()-1) json.append(",");
        }
        json.append("]");

        resp.getWriter().write(json.toString());
    }
}
