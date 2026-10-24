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

@WebServlet("/VehicleServlet")
public class VehicleServlet extends HttpServlet {

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
                    addVehicle(request, response);
                    break;

                case "update":
                    updateVehicle(request, response);
                    break;

                case "delete":
                    deleteVehicle(request, response);
                    break;

                default:
                    response.sendRedirect(
                            request.getContextPath()
                            + "/vehicles.jsp?error=invalidaction"
                    );
            }

        } catch (Exception e) {
            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/vehicles.jsp?error=database"
            );
        }
    }

    private void addVehicle(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String vehicleNumber =
                request.getParameter("vehicleNumber");

        String model =
                request.getParameter("model");

        String type =
                request.getParameter("type");

        String fuel =
                request.getParameter("fuel");

        String status =
                request.getParameter("status");

        String sql =
                "INSERT INTO vehicles "
                + "(vehicle_number, model, vehicle_type, fuel_type, status) "
                + "VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, vehicleNumber);
            ps.setString(2, model);
            ps.setString(3, type);
            ps.setString(4, fuel);
            ps.setString(5, status);

            ps.executeUpdate();
        }

        response.sendRedirect(
                request.getContextPath()
                + "/vehicles.jsp?success=added"
        );
    }

    private void updateVehicle(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String idText = request.getParameter("vehicleId");

        if (idText == null || !idText.matches("\\d+")) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/vehicles.jsp?error=invalidid"
            );
            return;
        }

        int vehicleId = Integer.parseInt(idText);

        String vehicleNumber =
                request.getParameter("vehicleNumber");

        String model =
                request.getParameter("model");

        String type =
                request.getParameter("type");

        String fuel =
                request.getParameter("fuel");

        String status =
                request.getParameter("status");

        String sql =
                "UPDATE vehicles SET vehicle_number = ?, model = ?, "
                + "vehicle_type = ?, fuel_type = ?, status = ? "
                + "WHERE vehicle_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, vehicleNumber);
            ps.setString(2, model);
            ps.setString(3, type);
            ps.setString(4, fuel);
            ps.setString(5, status);
            ps.setInt(6, vehicleId);

            int updated = ps.executeUpdate();

            if (updated == 0) {
                response.sendRedirect(
                        request.getContextPath()
                        + "/vehicles.jsp?error=notfound"
                );
                return;
            }
        }

        response.sendRedirect(
                request.getContextPath()
                + "/vehicles.jsp?success=updated"
        );
    }

    private void deleteVehicle(
            HttpServletRequest request,
            HttpServletResponse response)
            throws Exception {

        String idText = request.getParameter("vehicleId");

        if (idText == null || !idText.matches("\\d+")) {
            response.sendRedirect(
                    request.getContextPath()
                    + "/vehicles.jsp?error=invalidid"
            );
            return;
        }

        int vehicleId = Integer.parseInt(idText);

        try (Connection con = DBConnection.getConnection()) {

            // Prevent deleting a vehicle referenced by another module.
            String[] relatedQueries = {
                "SELECT COUNT(*) FROM trips WHERE vehicle_id = ?",
                "SELECT COUNT(*) FROM expenses WHERE vehicle_id = ?",
                "SELECT COUNT(*) FROM drivers WHERE vehicle_id = ?",
                "SELECT COUNT(*) FROM vehicle_maintenance WHERE vehicle_id = ?"
            };

            for (String sql : relatedQueries) {
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, vehicleId);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            response.sendRedirect(
                                    request.getContextPath()
                                    + "/vehicles.jsp?error=inuse"
                            );
                            return;
                        }
                    }
                }
            }

            String sql =
                    "DELETE FROM vehicles WHERE vehicle_id = ?";

            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, vehicleId);

                int deleted = ps.executeUpdate();

                if (deleted == 0) {
                    response.sendRedirect(
                            request.getContextPath()
                            + "/vehicles.jsp?error=notfound"
                    );
                    return;
                }
            }
        }

        response.sendRedirect(
                request.getContextPath()
                + "/vehicles.jsp?success=deleted"
        );
    }
}