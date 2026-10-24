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

@WebServlet("/DriverServlet")
public class DriverServlet extends HttpServlet {

    
@Override
protected void doPost(
        HttpServletRequest request,
        HttpServletResponse response)
        throws ServletException, IOException {

    String action = request.getParameter("action");

    if (action == null || action.isBlank()) {
        action = "add";
    }

    try {
        switch (action) {

            case "add":
                addDriver(request, response);
                break;

            case "update":
                updateDriver(request, response);
                break;

            case "delete":
                deleteDriver(request, response);
                break;

            default:
                response.sendRedirect(
                    request.getContextPath()
                    + "/drivers.jsp?error=invalidaction"
                );
        }

    } catch (Exception e) {
        e.printStackTrace();

        response.sendRedirect(
            request.getContextPath()
            + "/drivers.jsp?error=database"
        );
    }
}

private void addDriver(
        HttpServletRequest request,
        HttpServletResponse response) throws Exception {

    String name = request.getParameter("name");
    String mobile = request.getParameter("mobile");
    String licenseNo = request.getParameter("licenseNo");
    String status = request.getParameter("status");
    String vehicleId = request.getParameter("vehicleId");

    String sql = "INSERT INTO drivers "
            + "(name, mobile, license_no, status, vehicle_id) "
            + "VALUES (?, ?, ?, ?, ?)";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, name);
        ps.setString(2, mobile);
        ps.setString(3, licenseNo);
        ps.setString(4, status);

        if (vehicleId == null || vehicleId.isBlank()) {
            ps.setNull(5, java.sql.Types.INTEGER);
        } else {
            ps.setInt(5, Integer.parseInt(vehicleId));
        }

        ps.executeUpdate();
    }

    response.sendRedirect(
            request.getContextPath()
            + "/drivers.jsp?success=added"
    );
}

private void updateDriver(
        HttpServletRequest request,
        HttpServletResponse response) throws Exception {

    String idText = request.getParameter("driverId");

    if (idText == null || !idText.matches("\\d+")) {
        response.sendRedirect(
                request.getContextPath()
                + "/drivers.jsp?error=invalidid"
        );
        return;
    }

    int driverId = Integer.parseInt(idText);

    String name = request.getParameter("name");
    String mobile = request.getParameter("mobile");
    String licenseNo = request.getParameter("licenseNo");
    String status = request.getParameter("status");
    String vehicleId = request.getParameter("vehicleId");

    String sql = "UPDATE drivers SET "
            + "name = ?, mobile = ?, license_no = ?, "
            + "status = ?, vehicle_id = ? "
            + "WHERE driver_id = ?";

    try (Connection con = DBConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setString(1, name);
        ps.setString(2, mobile);
        ps.setString(3, licenseNo);
        ps.setString(4, status);

        if (vehicleId == null || vehicleId.isBlank()) {
            ps.setNull(5, java.sql.Types.INTEGER);
        } else {
            ps.setInt(5, Integer.parseInt(vehicleId));
        }

        ps.setInt(6, driverId);

        if (ps.executeUpdate() == 0) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/drivers.jsp?error=notfound"
            );
            return;
        }
    }

    response.sendRedirect(
            request.getContextPath()
            + "/drivers.jsp?success=updated"
    );
}

private void deleteDriver(
        HttpServletRequest request,
        HttpServletResponse response) throws Exception {

    String idText = request.getParameter("driverId");

    if (idText == null || !idText.matches("\\d+")) {
        response.sendRedirect(
                request.getContextPath()
                + "/drivers.jsp?error=invalidid"
        );
        return;
    }

    int driverId = Integer.parseInt(idText);

    try (Connection con = DBConnection.getConnection()) {

        // Prevent deleting a driver assigned to existing trips.
        String checkSql =
                "SELECT COUNT(*) FROM trips WHERE driver_id = ?";

        try (PreparedStatement check =
                     con.prepareStatement(checkSql)) {

            check.setInt(1, driverId);

            try (ResultSet rs = check.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    response.sendRedirect(
                            request.getContextPath()
                            + "/drivers.jsp?error=inuse"
                    );
                    return;
                }
            }
        }

        String sql =
                "DELETE FROM drivers WHERE driver_id = ?";

        try (PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, driverId);

            if (ps.executeUpdate() == 0) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/drivers.jsp?error=notfound"
                );
                return;
            }
        }
    }

    response.sendRedirect(
            request.getContextPath()
            + "/drivers.jsp?success=deleted"
    );
}

}