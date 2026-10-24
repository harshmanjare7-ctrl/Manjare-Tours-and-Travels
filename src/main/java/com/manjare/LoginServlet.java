package com.manjare;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Remove extra spaces
        if (username != null) {
            username = username.trim();
        }

        if (password != null) {
            password = password.trim();
        }

        // Check empty fields
        if (username == null || username.isEmpty()
                || password == null || password.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.jsp?error=invalid"
            );

            return;
        }

        // =====================================================
        // CHECK USERNAME AND PASSWORD FROM DATABASE
        // =====================================================

        String sql =
                "SELECT username FROM users "
                + "WHERE username = ? AND password = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    // Login successful
                    request.getSession(true).setAttribute("showServiceReminderPopup", true);
                    response.sendRedirect(
                            request.getContextPath()
                            + "/dashboard.jsp"
                    );

                } else {

                    // Invalid username/password
                    response.sendRedirect(
                            request.getContextPath()
                            + "/index.jsp?error=invalid"
                    );
                }
            }

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/index.jsp?error=database"
            );
        }
    }
}