package uz.pdp.mini_blok_with_jakarta.security;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import uz.pdp.mini_blok_with_jakarta.dao.AdminDao;
import uz.pdp.mini_blok_with_jakarta.dao.StartupDao;

@WebListener
public class AppStartup implements ServletContextListener {
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            new StartupDao().ensureIndexes();
            AdminDao dao = new AdminDao();
            UserFlags.loadBlocked(dao.blockedIds());
            UserFlags.loadVerified(dao.verifiedIds());
            System.out.println("[MilliyGram] ishga tushdi. Admin soni: " + dao.countAdmins());
        } catch (Exception e) {
            System.err.println("[MilliyGram] startup xatosi: " + e.getMessage());
        }
    }
}
