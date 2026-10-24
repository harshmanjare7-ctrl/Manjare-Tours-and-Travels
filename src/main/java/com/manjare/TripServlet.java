package com.manjare;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/TripServlet")
public class TripServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        // Edit and Delete are handled separately. If operation is absent or "add",
        // the original trip creation, payment, QR, and WhatsApp workflow continues.
        String operation = request.getParameter("operation");

        if ("delete".equalsIgnoreCase(operation)) {
            handleDelete(request, response);
            return;
        }

        if ("update".equalsIgnoreCase(operation)) {
            handleUpdate(request, response);
            return;
        }

        String customerId = request.getParameter("customerId");
        String vehicleId = request.getParameter("vehicleId");
        String driverId = request.getParameter("driverId");
        String tripType = request.getParameter("tripType");
        String pickup = request.getParameter("pickup");
        String destination = request.getParameter("destination");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String fare = request.getParameter("fare");
        String status = request.getParameter("status");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // 1. CONNECT TO DATABASE
            con = DBConnection.getConnection();

            // 2. INSERT TRIP
            String sql =
                    "INSERT INTO trips " +
                    "(customer_id, vehicle_id, driver_id, " +
                    "trip_type, pickup, destination, " +
                    "start_date, end_date, fare, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            ps = con.prepareStatement(
                    sql,
                    PreparedStatement.RETURN_GENERATED_KEYS
            );

            ps.setInt(1, Integer.parseInt(customerId));
            ps.setInt(2, Integer.parseInt(vehicleId));
            ps.setInt(3, Integer.parseInt(driverId));
            ps.setString(4, tripType);
            ps.setString(5, pickup);
            ps.setString(6, destination);
            ps.setDate(7, java.sql.Date.valueOf(startDate));

            if (endDate == null || endDate.isEmpty()) {
                ps.setNull(8, java.sql.Types.DATE);
            } else {
                ps.setDate(8, java.sql.Date.valueOf(endDate));
            }

            double fareAmount = Double.parseDouble(fare);
            ps.setDouble(9, fareAmount);
            ps.setString(10, status);
            ps.executeUpdate();

            // 3. GET GENERATED TRIP ID
            int tripId = 0;
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                tripId = rs.getInt(1);
            }
            rs.close();
            rs = null;
            ps.close();
            ps = null;

            // 4. CREATE PENDING PAYMENT
            String paymentSql =
                    "INSERT INTO payments " +
                    "(trip_id, amount, payment_mode, " +
                    "payment_status, payment_date) " +
                    "VALUES (?, ?, ?, ?, ?)";

            ps = con.prepareStatement(paymentSql);
            ps.setInt(1, tripId);
            ps.setDouble(2, fareAmount);
            ps.setString(3, "UPI");
            ps.setString(4, "Pending");
            ps.setNull(5, java.sql.Types.DATE);
            ps.executeUpdate();
            ps.close();
            ps = null;

            // 5. GET CUSTOMER DETAILS
            String customerName = "";
            String customerMobile = "";
            String customerSql =
                    "SELECT name, mobile " +
                    "FROM customers " +
                    "WHERE customer_id = ?";

            ps = con.prepareStatement(customerSql);
            ps.setInt(1, Integer.parseInt(customerId));
            rs = ps.executeQuery();
            if (rs.next()) {
                customerName = rs.getString("name");
                customerMobile = rs.getString("mobile");
            }
            rs.close();
            rs = null;
            ps.close();
            ps = null;

            // 6. GET VEHICLE NUMBER
            String vehicleNumber = "";
            String vehicleSql =
                    "SELECT vehicle_number " +
                    "FROM vehicles " +
                    "WHERE vehicle_id = ?";

            ps = con.prepareStatement(vehicleSql);
            ps.setInt(1, Integer.parseInt(vehicleId));
            rs = ps.executeQuery();
            if (rs.next()) {
                vehicleNumber = rs.getString("vehicle_number");
            }
            rs.close();
            rs = null;
            ps.close();
            ps = null;

            // 7. GET DRIVER NAME
            String driverName = "";
            String driverSql =
                    "SELECT name " +
                    "FROM drivers " +
                    "WHERE driver_id = ?";

            ps = con.prepareStatement(driverSql);
            ps.setInt(1, Integer.parseInt(driverId));
            rs = ps.executeQuery();
            if (rs.next()) {
                driverName = rs.getString("name");
            }
            rs.close();
            rs = null;
            ps.close();
            ps = null;

            // 8. CLEAN WHATSAPP NUMBER
            if (customerMobile != null) {
                customerMobile = customerMobile.replaceAll("[^0-9]", "");
                if (customerMobile.length() == 10) {
                    customerMobile = "91" + customerMobile;
                }
            }

            // 9. CREATE DIRECT UPI PAYMENT LINK
            String upiId = "8291718981@fam";
            String formattedFare = String.format(
                    java.util.Locale.US,
                    "%.2f",
                    fareAmount
            );

            String upiPaymentString =
                    "upi://pay"
                    + "?pa=" + upiId
                    + "&pn="
                    + URLEncoder.encode(
                            "MANJARE TOURS & TRAVELS",
                            StandardCharsets.UTF_8
                    )
                    + "&am=" + formattedFare
                    + "&cu=INR";

            // 10. CREATE QR CODE URL
            String qrCodeUrl =
                    "https://api.qrserver.com/v1/create-qr-code/"
                    + "?size=300x300"
                    + "&data="
                    + URLEncoder.encode(
                            upiPaymentString,
                            StandardCharsets.UTF_8
                    );

            // 11. CREATE WHATSAPP MESSAGE
            String message =
                    "MANJARE TOURS & TRAVELS\n"
                    + "========================\n\n"
                    + "TRIP CONFIRMATION\n\n"
                    + "Trip ID: #" + tripId + "\n\n"
                    + "Customer: " + customerName + "\n\n"
                    + "Vehicle: " + vehicleNumber + "\n"
                    + "Driver: " + driverName + "\n\n"
                    + "Trip Type: " + tripType + "\n\n"
                    + "Pickup: " + pickup + "\n"
                    + "Destination: " + destination + "\n\n"
                    + "Start Date: " + startDate + "\n"
                    + "End Date: "
                    + (endDate == null || endDate.isEmpty()
                        ? "Not specified"
                        : endDate)
                    + "\n\n"
                    + "Trip Fare: Rs. " + formattedFare + "\n"
                    + "Payment Status: PENDING\n\n"
                    + "========================\n"
                    + "PAYMENT\n"
                    + "========================\n\n"
                    + "PAY NOW:\n"
                    + upiPaymentString + "\n\n"
                    + "OR SCAN QR CODE:\n"
                    + qrCodeUrl + "\n\n"
                    + "PAYMENT INSTRUCTIONS:\n\n"
                    + "1. Click the PAY NOW link "
                    + "to open your UPI app.\n"
                    + "2. Complete the payment of Rs. "
                    + formattedFare + ".\n"
                    + "3. After successful payment, "
                    + "take a screenshot of the payment confirmation.\n"
                    + "4. Make sure the screenshot shows "
                    + "the Payment Successful message and "
                    + "Transaction ID / UPI Reference Number.\n"
                    + "5. Send the payment screenshot "
                    + "to Manjare Tours & Travels on WhatsApp "
                    + "for confirmation.\n\n"
                    + "Please make sure the payment is "
                    + "successfully completed before sending "
                    + "the screenshot.\n\n"
                    + "Thank you for choosing "
                    + "Manjare Tours & Travels.\n\n"
                    + "Have a safe and pleasant journey!";

            // 12. ENCODE WHATSAPP MESSAGE
            String encodedMessage = URLEncoder.encode(
                    message,
                    StandardCharsets.UTF_8
            );

            // 13. CREATE WHATSAPP URL
            String whatsappUrl =
                    "https://wa.me/"
                    + customerMobile
                    + "?text="
                    + encodedMessage;

            // 14. CLOSE CONNECTION
            con.close();
            con = null;

            // 15. REDIRECT
            response.sendRedirect(
                    request.getContextPath()
                    + "/trips.jsp"
                    + "?success=added"
                    + "&whatsapp="
                    + URLEncoder.encode(
                            whatsappUrl,
                            StandardCharsets.UTF_8
                    )
            );

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception ignored) {
            }
            response.sendRedirect(
                    request.getContextPath() + "/trips.jsp?error=database"
            );
        }
    }

    private void handleUpdate(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        String tripId = request.getParameter("tripId");
        String customerId = request.getParameter("customerId");
        String vehicleId = request.getParameter("vehicleId");
        String driverId = request.getParameter("driverId");
        String tripType = request.getParameter("tripType");
        String pickup = request.getParameter("pickup");
        String destination = request.getParameter("destination");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String fare = request.getParameter("fare");
        String status = request.getParameter("status");

        try (Connection con = DBConnection.getConnection()) {
            String sql =
                    "UPDATE trips SET customer_id = ?, vehicle_id = ?, driver_id = ?, " +
                    "trip_type = ?, pickup = ?, destination = ?, start_date = ?, " +
                    "end_date = ?, fare = ?, status = ? WHERE trip_id = ?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, Integer.parseInt(customerId));
                ps.setInt(2, Integer.parseInt(vehicleId));
                ps.setInt(3, Integer.parseInt(driverId));
                ps.setString(4, tripType);
                ps.setString(5, pickup);
                ps.setString(6, destination);
                ps.setDate(7, java.sql.Date.valueOf(startDate));
                if (endDate == null || endDate.trim().isEmpty()) {
                    ps.setNull(8, java.sql.Types.DATE);
                } else {
                    ps.setDate(8, java.sql.Date.valueOf(endDate));
                }
                double fareAmount = Double.parseDouble(fare);
                ps.setDouble(9, fareAmount);
                ps.setString(10, status);
                ps.setInt(11, Integer.parseInt(tripId));
                ps.executeUpdate();

                // Keep the amount in sync only for payments that are still pending.
                try (PreparedStatement paymentPs = con.prepareStatement(
                        "UPDATE payments SET amount = ? WHERE trip_id = ? AND payment_status = 'Pending'")) {
                    paymentPs.setDouble(1, fareAmount);
                    paymentPs.setInt(2, Integer.parseInt(tripId));
                    paymentPs.executeUpdate();
                }
            }

            response.sendRedirect(
                    request.getContextPath() + "/trips.jsp?success=updated"
            );
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/trips.jsp?error=database"
            );
        }
    }

    private void handleDelete(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        String tripId = request.getParameter("tripId");

        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // Remove related payment rows first to avoid a foreign-key conflict.
                try (PreparedStatement paymentPs = con.prepareStatement(
                        "DELETE FROM payments WHERE trip_id = ?")) {
                    paymentPs.setInt(1, Integer.parseInt(tripId));
                    paymentPs.executeUpdate();
                }

                try (PreparedStatement tripPs = con.prepareStatement(
                        "DELETE FROM trips WHERE trip_id = ?")) {
                    tripPs.setInt(1, Integer.parseInt(tripId));
                    int deleted = tripPs.executeUpdate();
                    if (deleted == 0) {
                        throw new IllegalArgumentException("Trip not found: " + tripId);
                    }
                }
                con.commit();
            } catch (Exception e) {
                con.rollback();
                throw e;
            }

            response.sendRedirect(
                    request.getContextPath() + "/trips.jsp?success=deleted"
            );
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(
                    request.getContextPath() + "/trips.jsp?error=database"
            );
        }
    }
}
