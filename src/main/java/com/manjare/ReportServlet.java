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
import java.sql.SQLException;

@WebServlet("/ReportServlet")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String fromDate = request.getParameter("fromDate");
        String toDate = request.getParameter("toDate");

        // Default values
        double totalIncome = 0;
        double totalExpenses = 0;
        double cashIncome = 0;
        double onlineIncome = 0;
        double pendingPayments = 0;

        int totalTrips = 0;

        try (Connection con = DBConnection.getConnection()) {

            /*
             * ==========================================
             * TOTAL TRIPS
             * ==========================================
             */

            String tripSql;

            PreparedStatement tripStmt;

            if (fromDate != null && toDate != null
                    && !fromDate.isEmpty()
                    && !toDate.isEmpty()) {

                tripSql =
                        "SELECT COUNT(*) FROM trips " +
                        "WHERE start_date BETWEEN ? AND ?";

                tripStmt = con.prepareStatement(tripSql);

                tripStmt.setString(1, fromDate);
                tripStmt.setString(2, toDate);

            } else {

                tripSql =
                        "SELECT COUNT(*) FROM trips";

                tripStmt = con.prepareStatement(tripSql);
            }

            try (ResultSet rs = tripStmt.executeQuery()) {

                if (rs.next()) {
                    totalTrips = rs.getInt(1);
                }
            }

            tripStmt.close();


            /*
             * ==========================================
             * TOTAL INCOME
             * ==========================================
             */

            String incomeSql;

            PreparedStatement incomeStmt;

            if (fromDate != null && toDate != null
                    && !fromDate.isEmpty()
                    && !toDate.isEmpty()) {

                incomeSql =
                        "SELECT COALESCE(SUM(fare),0) " +
                        "FROM trips " +
                        "WHERE start_date BETWEEN ? AND ? " +
                        "AND status <> 'Cancelled'";

                incomeStmt =
                        con.prepareStatement(incomeSql);

                incomeStmt.setString(1, fromDate);
                incomeStmt.setString(2, toDate);

            } else {

                incomeSql =
                        "SELECT COALESCE(SUM(fare),0) " +
                        "FROM trips " +
                        "WHERE status <> 'Cancelled'";

                incomeStmt =
                        con.prepareStatement(incomeSql);
            }

            try (ResultSet rs =
                    incomeStmt.executeQuery()) {

                if (rs.next()) {
                    totalIncome = rs.getDouble(1);
                }
            }

            incomeStmt.close();


            /*
             * ==========================================
             * TOTAL EXPENSES
             * ==========================================
             */

            String expenseSql;

            PreparedStatement expenseStmt;

            if (fromDate != null && toDate != null
                    && !fromDate.isEmpty()
                    && !toDate.isEmpty()) {

                expenseSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM expenses " +
                        "WHERE expense_date BETWEEN ? AND ?";

                expenseStmt =
                        con.prepareStatement(expenseSql);

                expenseStmt.setString(1, fromDate);
                expenseStmt.setString(2, toDate);

            } else {

                expenseSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM expenses";

                expenseStmt =
                        con.prepareStatement(expenseSql);
            }

            try (ResultSet rs =
                    expenseStmt.executeQuery()) {

                if (rs.next()) {
                    totalExpenses = rs.getDouble(1);
                }
            }

            expenseStmt.close();


            /*
             * ==========================================
             * CASH INCOME
             * ==========================================
             */

            String cashSql;

            PreparedStatement cashStmt;

            if (fromDate != null && toDate != null
                    && !fromDate.isEmpty()
                    && !toDate.isEmpty()) {

                cashSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM payments " +
                        "WHERE payment_mode = 'Cash' " +
                        "AND payment_status = 'Paid' " +
                        "AND payment_date BETWEEN ? AND ?";

                cashStmt =
                        con.prepareStatement(cashSql);

                cashStmt.setString(1, fromDate);
                cashStmt.setString(2, toDate);

            } else {

                cashSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM payments " +
                        "WHERE payment_mode = 'Cash' " +
                        "AND payment_status = 'Paid'";

                cashStmt =
                        con.prepareStatement(cashSql);
            }

            try (ResultSet rs =
                    cashStmt.executeQuery()) {

                if (rs.next()) {
                    cashIncome = rs.getDouble(1);
                }
            }

            cashStmt.close();


            /*
             * ==========================================
             * ONLINE INCOME
             * ==========================================
             */

            String onlineSql;

            PreparedStatement onlineStmt;

            if (fromDate != null && toDate != null
                    && !fromDate.isEmpty()
                    && !toDate.isEmpty()) {

                onlineSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM payments " +
                        "WHERE payment_mode = 'Online' " +
                        "AND payment_status = 'Paid' " +
                        "AND payment_date BETWEEN ? AND ?";

                onlineStmt =
                        con.prepareStatement(onlineSql);

                onlineStmt.setString(1, fromDate);
                onlineStmt.setString(2, toDate);

            } else {

                onlineSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM payments " +
                        "WHERE payment_mode = 'Online' " +
                        "AND payment_status = 'Paid'";

                onlineStmt =
                        con.prepareStatement(onlineSql);
            }

            try (ResultSet rs =
                    onlineStmt.executeQuery()) {

                if (rs.next()) {
                    onlineIncome = rs.getDouble(1);
                }
            }

            onlineStmt.close();


            /*
             * ==========================================
             * PENDING PAYMENTS
             * ==========================================
             */

            String pendingSql;

            PreparedStatement pendingStmt;

            if (fromDate != null && toDate != null
                    && !fromDate.isEmpty()
                    && !toDate.isEmpty()) {

                pendingSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM payments " +
                        "WHERE payment_status = 'Pending' " +
                        "AND payment_date BETWEEN ? AND ?";

                pendingStmt =
                        con.prepareStatement(pendingSql);

                pendingStmt.setString(1, fromDate);
                pendingStmt.setString(2, toDate);

            } else {

                pendingSql =
                        "SELECT COALESCE(SUM(amount),0) " +
                        "FROM payments " +
                        "WHERE payment_status = 'Pending'";
                
                pendingStmt =
                        con.prepareStatement(pendingSql);
            }

            try (ResultSet rs =
                    pendingStmt.executeQuery()) {

                if (rs.next()) {
                    pendingPayments = rs.getDouble(1);
                }
            }

            pendingStmt.close();


            /*
             * ==========================================
             * SEND DATA TO JSP
             * ==========================================
             */

            double netIncome =
                    totalIncome - totalExpenses;

            request.setAttribute(
                    "totalIncome",
                    totalIncome
            );

            request.setAttribute(
                    "totalExpenses",
                    totalExpenses
            );

            request.setAttribute(
                    "netIncome",
                    netIncome
            );

            request.setAttribute(
                    "totalTrips",
                    totalTrips
            );

            request.setAttribute(
                    "cashIncome",
                    cashIncome
            );

            request.setAttribute(
                    "onlineIncome",
                    onlineIncome
            );

            request.setAttribute(
                    "pendingPayments",
                    pendingPayments
            );

            request.setAttribute(
                    "fromDate",
                    fromDate
            );

            request.setAttribute(
                    "toDate",
                    toDate
            );


            request.getRequestDispatcher(
                    "reports.jsp"
            ).forward(request, response);


        } catch (SQLException e) {

            e.printStackTrace();

            request.setAttribute(
                    "error",
                    "Unable to generate report: "
                    + e.getMessage()
            );

            request.getRequestDispatcher(
                    "reports.jsp"
            ).forward(request, response);
        }
    }
}