package com.manjare;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/ResetPasswordServlet")
public class ResetPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // =====================================================
        // GET SESSION
        // =====================================================

        HttpSession session = request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                    "forgotPassword.jsp?error=session"
            );

            return;
        }


        // =====================================================
        // CHECK OTP VERIFICATION
        // =====================================================

        Boolean otpVerified =
                (Boolean) session.getAttribute("otpVerified");

        String username =
                (String) session.getAttribute("resetUsername");


        if (!Boolean.TRUE.equals(otpVerified)
                || username == null
                || username.isEmpty()) {

            response.sendRedirect(
                    "forgotPassword.jsp?error=session"
            );

            return;
        }


        // =====================================================
        // GET PASSWORDS
        // =====================================================

        String newPassword =
                request.getParameter("newPassword");

        String confirmPassword =
                request.getParameter("confirmPassword");


        if (newPassword == null
                || confirmPassword == null
                || newPassword.isEmpty()
                || confirmPassword.isEmpty()) {

            response.sendRedirect(
                    "resetPassword.jsp?error=empty"
            );

            return;
        }


        // =====================================================
        // CHECK PASSWORD MATCH
        // =====================================================

        if (!newPassword.equals(confirmPassword)) {

            response.sendRedirect(
                    "resetPassword.jsp?error=mismatch"
            );

            return;
        }


        // =====================================================
        // UPDATE PASSWORD
        // =====================================================

        String sql =
                "UPDATE users SET password = ? "
                + "WHERE username = ?";


        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPassword);
            ps.setString(2, username);

            int rowsUpdated =
                    ps.executeUpdate();


            if (rowsUpdated == 0) {

                response.sendRedirect(
                        "resetPassword.jsp?error=failed"
                );

                return;
            }


            // =================================================
            // DELETE USED OTP
            // =================================================

            String deleteOtpSql =
                    "DELETE FROM password_reset "
                    + "WHERE username = ?";


            try (PreparedStatement deletePs =
                         con.prepareStatement(deleteOtpSql)) {

                deletePs.setString(1, username);

                deletePs.executeUpdate();
            }


            // =================================================
            // REMOVE RESET SESSION DATA
            // =================================================

            session.removeAttribute("resetUsername");
            session.removeAttribute("otpVerified");


            // =================================================
            // SUCCESS
            // =================================================

            response.sendRedirect(
                    "index.jsp?reset=success"
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "resetPassword.jsp?error=failed"
            );
        }
    }
}