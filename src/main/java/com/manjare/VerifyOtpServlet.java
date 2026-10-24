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
import java.sql.ResultSet;

@WebServlet("/VerifyOtpServlet")
public class VerifyOtpServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Get OTP entered by user
        String enteredOtp = request.getParameter("otp");

        if (enteredOtp != null) {
            enteredOtp = enteredOtp.trim();
        }

        // Get session
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("verifyOtp.jsp?error=session");
            return;
        }

        // Get username saved by ForgotPasswordServlet
        String username =
                (String) session.getAttribute("resetUsername");

        if (username == null || username.isEmpty()) {
            response.sendRedirect("verifyOtp.jsp?error=session");
            return;
        }

        // Check empty OTP
        if (enteredOtp == null || enteredOtp.isEmpty()) {
            response.sendRedirect("verifyOtp.jsp?error=invalid");
            return;
        }


        // =====================================================
        // GET OTP FROM DATABASE
        // =====================================================

        String sql =
                "SELECT otp, expiry_time "
                + "FROM password_reset "
                + "WHERE username = ?";


        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);

            try (ResultSet rs = ps.executeQuery()) {

                if (!rs.next()) {

                    response.sendRedirect(
                            "verifyOtp.jsp?error=invalid"
                    );

                    return;
                }

                String databaseOtp =
                        rs.getString("otp");

                java.sql.Timestamp expiryTime =
                        rs.getTimestamp("expiry_time");


                // =================================================
                // CHECK OTP
                // =================================================

                if (!databaseOtp.equals(enteredOtp)) {

                    response.sendRedirect(
                            "verifyOtp.jsp?error=invalid"
                    );

                    return;
                }


                // =================================================
                // CHECK EXPIRY
                // =================================================

                if (expiryTime == null
                        || expiryTime.before(
                                new java.util.Date())) {

                    response.sendRedirect(
                            "verifyOtp.jsp?error=expired"
                    );

                    return;
                }


                // =================================================
                // OTP IS CORRECT
                // =================================================

                session.setAttribute(
                        "otpVerified",
                        true
                );

                session.setAttribute(
                        "resetUsername",
                        username
                );


                // Go to password reset page
                response.sendRedirect(
                        "resetPassword.jsp"
                );
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    "verifyOtp.jsp?error=database"
            );
        }
    }
}