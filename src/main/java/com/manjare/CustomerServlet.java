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
import java.sql.Types;

@WebServlet("/CustomerServlet")
public class CustomerServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            action = "add"; // Keeps the original Add Customer form compatible.
        }

        try {
            switch (action) {
                case "add":
                    addCustomer(request, response);
                    break;

                case "update":
                    updateCustomer(request, response);
                    break;

                case "delete":
                    deleteCustomer(request, response);
                    break;

                default:
                    response.sendRedirect(
                            request.getContextPath()
                            + "/customers.jsp?error=invalidaction"
                    );
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath()
                    + "/customers.jsp?error=database"
            );
        }
    }

    private void addCustomer(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        String name = request.getParameter("name");
        String mobile = request.getParameter("mobile");
        String address = request.getParameter("address");

        String sql = "INSERT INTO customers (name, mobile, address) VALUES (?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, mobile);
            ps.setString(3, address);
            ps.executeUpdate();
        }

        response.sendRedirect(
                request.getContextPath() + "/customers.jsp?success=added"
        );
    }

    private void updateCustomer(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        int customerId = parseCustomerId(request.getParameter("customerId"));
        String name = request.getParameter("name");
        String mobile = request.getParameter("mobile");
        String address = request.getParameter("address");

        String sql = "UPDATE customers SET name = ?, mobile = ?, address = ? WHERE customer_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setString(2, mobile);
            ps.setString(3, address);
            ps.setInt(4, customerId);

            int rowsUpdated = ps.executeUpdate();

            if (rowsUpdated == 0) {
                response.sendRedirect(
                        request.getContextPath() + "/customers.jsp?error=notfound"
                );
                return;
            }
        }

        response.sendRedirect(
                request.getContextPath() + "/customers.jsp?success=updated"
        );
    }

    private void deleteCustomer(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        int customerId = parseCustomerId(request.getParameter("customerId"));

        String sql = "DELETE FROM customers WHERE customer_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, customerId);

            int rowsDeleted = ps.executeUpdate();

            if (rowsDeleted == 0) {
                response.sendRedirect(
                        request.getContextPath() + "/customers.jsp?error=notfound"
                );
                return;
            }
        }

        response.sendRedirect(
                request.getContextPath() + "/customers.jsp?success=deleted"
        );
    }

    private int parseCustomerId(String idValue) {
        if (idValue == null || !idValue.matches("\\d+")) {
            throw new IllegalArgumentException("Invalid customer ID");
        }

        int customerId = Integer.parseInt(idValue);
        if (customerId <= 0) {
            throw new IllegalArgumentException("Invalid customer ID");
        }

        return customerId;
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/customers.jsp");
    }
}
