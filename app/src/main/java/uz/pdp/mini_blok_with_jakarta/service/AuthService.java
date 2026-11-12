package uz.pdp.mini_blok_with_jakarta.service;

import uz.pdp.mini_blok_with_jakarta.dao.AuthUserDao;
import uz.pdp.mini_blok_with_jakarta.dto.LoginDTO;
import uz.pdp.mini_blok_with_jakarta.dto.LoginSuccessDTO;
import uz.pdp.mini_blok_with_jakarta.dto.RegisterDTO;
import uz.pdp.mini_blok_with_jakarta.entity.AuthUser;
import uz.pdp.mini_blok_with_jakarta.enums.Role;
import uz.pdp.mini_blok_with_jakarta.enums.Status;
import uz.pdp.mini_blok_with_jakarta.utils.PasswordUtils;

import java.util.Optional;

public class AuthService {
    private final AuthUserDao ad = new AuthUserDao();

    public LoginSuccessDTO register(RegisterDTO registerDTO) {
        Optional<AuthUser> byUsername = ad.findByUsername(registerDTO.username());
        if (byUsername.isPresent()) {
            return null;
        }

        AuthUser authUser = AuthUser.builder()
                .fullName(registerDTO.fullname())
                .username(registerDTO.username())
                .password(PasswordUtils.hash(registerDTO.password()))
                .status(Status.ACTIVE)
                .role(Role.USER)
                .build();

        ad.save(authUser);

        return new LoginSuccessDTO(authUser.getId(), authUser.getRole());
    }

    public LoginSuccessDTO loginDTO(LoginDTO loginDTO) {
        if (loginDTO.username() == null || loginDTO.password() == null) return null;
        Optional<AuthUser> optional = ad.findByUsername(loginDTO.username().trim());
        if (optional.isEmpty()) return null;
        AuthUser authUser = optional.get();
        if (!PasswordUtils.matches(loginDTO.password(), authUser.getPassword())) return null;

        // eski oddiy matnli parolni avtomatik hash'ga o'tkazamiz
        if (!PasswordUtils.isHashed(authUser.getPassword())) {
            authUser.setPassword(PasswordUtils.hash(loginDTO.password()));
            ad.update(authUser);
        }
        return new LoginSuccessDTO(authUser.getId(), authUser.getRole());
    }

    public void changePassword(AuthUser user, String newPassword) {
        user.setPassword(PasswordUtils.hash(newPassword));
        ad.update(user);
    }
}
