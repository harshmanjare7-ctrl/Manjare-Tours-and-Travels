
package com.manjare;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;

@WebServlet("/PaymentServlet")
public class PaymentServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            action = "add";
        }

        String contextPath = request.getContextPath();

        try {
            // DELETE PAYMENT
            if ("delete".equalsIgnoreCase(action)) {

                int paymentId = Integer.parseInt(
                    request.getParameter("paymentId")
                );

                String sql =
                    "DELETE FROM payments WHERE payment_id = ?";

                try (
                    Connection con = DBConnection.getConnection();
                    PreparedStatement ps = con.prepareStatement(sql)
                ) {
                    ps.setInt(1, paymentId);

                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect(
                            contextPath + "/payments.jsp?success=deleted"
                        );
                    } else {
                        response.sendRedirect(
                            contextPath + "/payments.jsp?error=notfound"
                        );
                    }
                }

                return;
            }

            // READ FORM VALUES
            int tripId = Integer.parseInt(
                request.getParameter("tripId")
            );

            BigDecimal amount = new BigDecimal(
                request.getParameter("amount")
            );

            String paymentMode =
                request.getParameter("paymentMode");

            String paymentStatus =
                request.getParameter("paymentStatus");

            Date paymentDate = Date.valueOf(
                request.getParameter("paymentDate")
            );

            // VALIDATE AMOUNT
            if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                response.sendRedirect(
                    contextPath + "/payments.jsp?error=database"
                );
                return;
            }

            // VALIDATE PAYMENT MODE
            if (paymentMode == null ||
                !(paymentMode.equals("Cash") ||
                  paymentMode.equals("UPI") ||
                  paymentMode.equals("Card") ||
                  paymentMode.equals("Bank Transfer"))) {

                response.sendRedirect(
                    contextPath + "/payments.jsp?error=database"
                );
                return;
            }

            // VALIDATE PAYMENT STATUS
            if (paymentStatus == null ||
                !(paymentStatus.equals("Paid") ||
                  paymentStatus.equals("Pending") ||
                  paymentStatus.equals("Refunded"))) {

                response.sendRedirect(
                    contextPath + "/payments.jsp?error=database"
                );
                return;
            }

            // UPDATE PAYMENT
            if ("update".equalsIgnoreCase(action)) {

                int paymentId = Integer.parseInt(
                    request.getParameter("paymentId")
                );

                String sql =
                    "UPDATE payments SET " +
                    "trip_id = ?, " +
                    "amount = ?, " +
                    "payment_mode = ?, " +
                    "payment_status = ?, " +
                    "payment_date = ? " +
                    "WHERE payment_id = ?";

                try (
                    Connection con = DBConnection.getConnection();
                    PreparedStatement ps = con.prepareStatement(sql)
                ) {
                    ps.setInt(1, tripId);
                    ps.setBigDecimal(2, amount);
                    ps.setString(3, paymentMode);
                    ps.setString(4, paymentStatus);
                    ps.setDate(5, paymentDate);
                    ps.setInt(6, paymentId);

                    int rows = ps.executeUpdate();

                    if (rows > 0) {
                        response.sendRedirect(
                            contextPath + "/payments.jsp?success=updated"
                        );
                    } else {
                        response.sendRedirect(
                            contextPath + "/payments.jsp?error=notfound"
                        );
                    }
                }

                return;
            }

            // ADD PAYMENT
            if ("add".equalsIgnoreCase(action)) {

                String sql =
                    "INSERT INTO payments " +
                    "(trip_id, amount, payment_mode, " +
                    "payment_status, payment_date) " +
                    "VALUES (?, ?, ?, ?, ?)";

                try (
                    Connection con = DBConnection.getConnection();
                    PreparedStatement ps = con.prepareStatement(sql)
                ) {
                    ps.setInt(1, tripId);
                    ps.setBigDecimal(2, amount);
                    ps.setString(3, paymentMode);
                    ps.setString(4, paymentStatus);
                    ps.setDate(5, paymentDate);

                    ps.executeUpdate();
                }

                response.sendRedirect(
                    contextPath + "/payments.jsp?success=added"
                );

                return;
            }

            // UNKNOWN ACTION
            response.sendRedirect(
                contextPath + "/payments.jsp?error=database"
            );

        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                contextPath + "/payments.jsp?error=database"
            );
        }
    }
}