package com.manjare;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

@WebServlet("/MaintenanceServlet")
public class MaintenanceServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if ("add".equals(action)) {

            addMaintenance(request, response);

        } else if ("delete".equals(action)) {

            deleteMaintenance(request, response);

        } else {

            response.sendRedirect(
                    request.getContextPath()
                    + "/maintenance.jsp"
            );
        }
    }


    private void addMaintenance(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String vehicleId =
                request.getParameter("vehicle_id");

        String maintenanceType =
                request.getParameter("maintenance_type");

        String maintenanceDate =
                request.getParameter("maintenance_date");

        String cost =
                request.getParameter("cost");

        String description =
                request.getParameter("description");

        String nextServiceDate =
                request.getParameter("next_service_date");


        String sql =
                "INSERT INTO vehicle_maintenance " +
                "(vehicle_id, maintenance_type, " +
                "maintenance_date, cost, description, " +
                "next_service_date) " +
                "VALUES (?, ?, ?, ?, ?, ?)";


        try (Connection con =
                     DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement(sql)) {


            ps.setInt(
                    1,
                    Integer.parseInt(vehicleId)
            );

            ps.setString(
                    2,
                    maintenanceType
            );

            ps.setString(
                    3,
                    maintenanceDate
            );

            ps.setDouble(
                    4,
                    Double.parseDouble(cost)
            );

            ps.setString(
                    5,
                    description
            );


            if (nextServiceDate == null
                    || nextServiceDate.isEmpty()) {

                ps.setNull(
                        6,
                        java.sql.Types.DATE
                );

            } else {

                ps.setString(
                        6,
                        nextServiceDate
                );
            }


            ps.executeUpdate();


            response.sendRedirect(
                    request.getContextPath()
                    + "/maintenance.jsp?success=added"
            );


        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/maintenance.jsp?error=add"
            );
        }
    }


    private void deleteMaintenance(
            HttpServletRequest request,
            HttpServletResponse response)
            throws IOException {

        String id =
                request.getParameter("maintenance_id");


        String sql =
                "DELETE FROM vehicle_maintenance " +
                "WHERE maintenance_id = ?";


        try (Connection con =
                     DBConnection.getConnection();
             PreparedStatement ps =
                     con.prepareStatement(sql)) {


            ps.setInt(
                    1,
                    Integer.parseInt(id)
            );

            ps.executeUpdate();


            response.sendRedirect(
                    request.getContextPath()
                    + "/maintenance.jsp?success=deleted"
            );


        } catch (Exception e) {

            e.printStackTrace();

            response.sendRedirect(
                    request.getContextPath()
                    + "/maintenance.jsp?error=delete"
            );
        }
    }
}