package com.manjare;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import java.util.Properties;
import java.util.Random;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    // =========================================================
    // GMAIL DETAILS
    // =========================================================

    // Put the Gmail address that will SEND the OTP here.
    private static final String SENDER_EMAIL = "harshmanjare7@gmail.com";

    // Put your Google APP PASSWORD here.
    // DO NOT use your normal Gmail password.
    private static final String APP_PASSWORD = "ntry karv beck btxj";


    // =========================================================
    // DO POST
    // =========================================================

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String phone = request.getParameter("phone");
        String email = request.getParameter("email");

        // Remove unnecessary spaces
        if (phone != null) {
            phone = phone.trim();
        }

        if (email != null) {
            email = email.trim().toLowerCase();
        }

        // Check empty values
        if (phone == null || phone.isEmpty()
                || email == null || email.isEmpty()) {

            response.sendRedirect("forgotPassword.jsp?error=empty");
            return;
        }


        // =====================================================
        // CHECK USER IN DATABASE
        // =====================================================

        String username = null;

        String sql = "SELECT username, email, phone "
                   + "FROM users "
                   + "WHERE phone = ? AND email = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, phone);
            ps.setString(2, email);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    username = rs.getString("username");
                }
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect("forgotPassword.jsp?error=database");
            return;
        }


        // =====================================================
        // USER NOT FOUND
        // =====================================================

        if (username == null) {

            response.sendRedirect("forgotPassword.jsp?error=invalid");
            return;
        }


        // =====================================================
        // GENERATE 6 DIGIT OTP
        // =====================================================

        Random random = new Random();

        String otp = String.valueOf(
                100000 + random.nextInt(900000)
        );


        // =====================================================
        // OTP EXPIRY = 5 MINUTES
        // =====================================================

        LocalDateTime expiryTime = LocalDateTime.now().plusMinutes(5);

        DateTimeFormatter formatter =
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

        String expiry = expiryTime.format(formatter);


        // =====================================================
        // DELETE OLD OTP
        // =====================================================

        String deleteSql =
                "DELETE FROM password_reset WHERE username = ?";


        // =====================================================
        // INSERT NEW OTP
        // =====================================================

        String insertSql =
                "INSERT INTO password_reset "
                + "(username, otp, expiry_time) "
                + "VALUES (?, ?, ?)";


        try (Connection con = DBConnection.getConnection()) {

            // Delete previous OTP
            try (PreparedStatement deletePs =
                         con.prepareStatement(deleteSql)) {

                deletePs.setString(1, username);
                deletePs.executeUpdate();
            }


            // Insert new OTP
            try (PreparedStatement insertPs =
                         con.prepareStatement(insertSql)) {

                insertPs.setString(1, username);
                insertPs.setString(2, otp);
                insertPs.setString(3, expiry);

                insertPs.executeUpdate();
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect("forgotPassword.jsp?error=database");
            return;
        }


        // =====================================================
        // SEND OTP TO EMAIL
        // =====================================================

        try {

            sendOTP(email, otp);

        } catch (Exception e) {

            e.printStackTrace();

            // Remove OTP if email failed
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps =
                         con.prepareStatement(
                                 "DELETE FROM password_reset WHERE username = ?")) {

                ps.setString(1, username);
                ps.executeUpdate();

            } catch (Exception deleteError) {
                deleteError.printStackTrace();
            }

            response.sendRedirect("forgotPassword.jsp?error=email");
            return;
        }


        // =====================================================
        // SAVE USERNAME IN SESSION
        // =====================================================

        request.getSession().setAttribute(
                "resetUsername",
                username
        );


        // =====================================================
        // GO TO OTP PAGE
        // =====================================================

        response.sendRedirect("verifyOtp.jsp");

    }


    // =========================================================
    // SEND OTP USING GMAIL
    // =========================================================

    private void sendOTP(String receiverEmail, String otp)
            throws Exception {

        Properties properties = new Properties();

        properties.put(
                "mail.smtp.host",
                "smtp.gmail.com"
        );

        properties.put(
                "mail.smtp.port",
                "587"
        );

        properties.put(
                "mail.smtp.auth",
                "true"
        );

        properties.put(
                "mail.smtp.starttls.enable",
                "true"
        );


        // Gmail authentication
        Session session = Session.getInstance(
                properties,
                new Authenticator() {

                    @Override
                    protected PasswordAuthentication
                    getPasswordAuthentication() {

                        return new PasswordAuthentication(
                                SENDER_EMAIL,
                                APP_PASSWORD
                        );
                    }
                }
        );


        // Create email
        Message message = new MimeMessage(session);

        message.setFrom(
                new InternetAddress(SENDER_EMAIL)
        );

        message.setRecipients(
                Message.RecipientType.TO,
                InternetAddress.parse(receiverEmail)
        );

        message.setSubject(
                "Manjare Tours & Travels - Password Reset OTP"
        );

        message.setText(
                "Hello,\n\n"
                + "Your password reset OTP is:\n\n"
                + otp
                + "\n\n"
                + "This OTP is valid for 5 minutes."
                + "\n\n"
                + "If you did not request a password reset, "
                + "please ignore this email."
                + "\n\n"
                + "Manjare Tours & Travels"
        );


        // Send email
        Transport.send(message);
    }
}