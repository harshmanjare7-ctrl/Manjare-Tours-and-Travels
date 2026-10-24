
package com.manjare;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/ExpenseServlet")
public class ExpenseServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null) {
            action = "add";
        }

        String expenseId = request.getParameter("expenseId");
        String vehicleId = request.getParameter("vehicleId");
        String expenseType = request.getParameter("expenseType");
        String amount = request.getParameter("amount");
        String expenseDate = request.getParameter("expenseDate");
        String description = request.getParameter("description");

        try {
            if ("delete".equals(action)) {

                String sql =
                        "DELETE FROM expenses WHERE expense_id = ?";

                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql)) {

                    ps.setInt(1, Integer.parseInt(expenseId));

                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect(
                                request.getContextPath()
                                + "/expenses.jsp?success=deleted");
                    } else {
                        response.sendRedirect(
                                request.getContextPath()
                                + "/expenses.jsp?error=notfound");
                    }
                }

                return;
            }

            if ("update".equals(action)) {

                String sql =
                        "UPDATE expenses SET vehicle_id = ?, "
                        + "expense_type = ?, amount = ?, "
                        + "expense_date = ?, description = ? "
                        + "WHERE expense_id = ?";

                try (Connection con = DBConnection.getConnection();
                     PreparedStatement ps = con.prepareStatement(sql)) {

                    ps.setInt(1, Integer.parseInt(vehicleId));
                    ps.setString(2, expenseType);
                    ps.setDouble(3, Double.parseDouble(amount));
                    ps.setDate(
                            4,
                            java.sql.Date.valueOf(expenseDate));

                    ps.setString(5, description);
                    ps.setInt(6, Integer.parseInt(expenseId));

                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect(
                                request.getContextPath()
                                + "/expenses.jsp?success=updated");
                    } else {
                        response.sendRedirect(
                                request.getContextPath()
                                + "/expenses.jsp?error=notfound");
                    }
                }

                return;
            }

            // EXISTING ADD EXPENSE FUNCTIONALITY

            String sql =
                    "INSERT INTO expenses "
                    + "(vehicle_id, expense_type, amount, "
                    + "expense_date, description) "
                    + "VALUES (?, ?, ?, ?, ?)";

            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {

                ps.setInt(1, Integer.parseInt(vehicleId));
                ps.setString(2, expenseType);
                ps.setDouble(3, Double.parseDouble(amount));
                ps.setDate(
                        4,
                        java.sql.Date.valueOf(expenseDate));

                ps.setString(5, description);

                ps.executeUpdate();
            }

            response.sendRedirect(
                    request.getContextPath()
                    + "/expenses.jsp?success=added");

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/expenses.jsp?error=database");
        }
    }
}