<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ page import="java.sql.*" %>

<%@ page import="com.manjare.DBConnection" %>

<%!
    private String escapeTripAttribute(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;")
                    .replace("\"", "&quot;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;");
    }
%>



<!DOCTYPE html>

<html lang="en">



<head>



    <meta charset="UTF-8">



    <meta name="viewport"

          content="width=device-width, initial-scale=1.0">



    <title>

        Trips | Manjare Tours & Travels

    </title>



    <style>



        * {

            margin: 0;

            padding: 0;

            box-sizing: border-box;

        }



        body {

            font-family: Arial, Helvetica, sans-serif;

            background:

                linear-gradient(

                    rgba(7, 25, 43, 0.35),

                    rgba(7, 25, 43, 0.50)

                ),

                url("images/dashboard-bg.png");

                background-size: cover;

                background-position: center top;

                background-attachment: fixed;

                background-repeat: no-repeat;

                color: white;

                min-height: 100vh;

        }



        .navbar {

            height: 80px;

            background: #0b2239;

            display: flex;

            align-items: center;

            justify-content: space-between;

            padding: 0 40px;

            border-bottom: 1px solid rgba(255,255,255,0.15);

            position: sticky;

            top: 0;

            z-index: 1000;

        }



        .nav-left {

            display: flex;

            align-items: center;

            gap: 25px;

        }



        .menu-btn {

            width: 42px;

            height: 42px;

            border: none;

            background: transparent;

            cursor: pointer;

            display: flex;

            flex-direction: column;

            justify-content: center;

            gap: 6px;

            padding: 8px;

        }





        .menu-btn span {

            display: block;

            width: 25px;

            height: 3px;

            background: white;

            border-radius: 3px;

            transition: 0.3s;

        }





        .menu-btn:hover span {

            background: #f4b942;

        }



        .logo {

            font-size: 24px;

            font-weight: bold;

            letter-spacing: 3px;

        }



        .logo span {

            display: block;

            font-size: 11px;

            color: #f4b942;

            letter-spacing: 4px;

            margin-top: 4px;

        }



        /* =========================

           BACK BUTTON

        ========================== */



        .back {



            color: white;



            border:

                1px solid #d4af37;



            padding: 10px 18px;



            text-decoration: none;



            border-radius: 6px;



            transition: 0.3s;

        }





        .back:hover {



            background: #d4af37;



            color: #0b2239;

        }





        /* =========================

           SIDEBAR

        ========================== */



        .sidebar {

            position: fixed;

            top: 0;

            left: -300px;

            width: 290px;

            height: 100vh;

            background: rgba(11, 34, 57, 0.82);

    backdrop-filter: blur(10px);

    -webkit-backdrop-filter: blur(10px);

            z-index: 2000;

            padding: 25px 20px;

            box-shadow: 5px 0 20px rgba(0,0,0,0.35);

            transition: left 0.35s ease;

        }



        .sidebar.active {

            left: 0;

        }



        .sidebar-header {

            display: flex;

            justify-content: space-between;

            align-items: center;

            padding-bottom: 20px;

            border-bottom: 1px solid rgba(255,255,255,0.12);

            margin-bottom: 20px;

        }



        .sidebar-title {

            font-size: 21px;

            font-weight: bold;

        }



        .sidebar-title span {

            display: block;

            color: #f4b942;

            font-size: 10px;

            letter-spacing: 3px;

            margin-top: 4px;

        }



        .close-btn {

            background: transparent;

            border: none;

            color: white;

            font-size: 28px;

            cursor: pointer;

        }



        .close-btn:hover {

            color: #f4b942;

        }



        .sidebar-menu {

            list-style: none;

        }



        .sidebar-menu li {

            margin-bottom: 8px;

        }



        .sidebar-menu a {

            display: flex;

            align-items: center;

            gap: 14px;

            text-decoration: none;

            color: rgba(255,255,255,0.85);

            padding: 13px 15px;

            border-radius: 8px;

            font-size: 15px;

            transition: 0.25s;

        }



        .sidebar-menu a:hover {

            background: rgba(244,185,66,0.12);

            color: #f4b942;

            transform: translateX(4px);

        }



        .sidebar-icon {

            font-size: 20px;

            width: 25px;

            text-align: center;

        }



        .overlay {

            position: fixed;

            top: 0;

            left: 0;

            width: 100%;

            height: 100%;

            background: rgba(0,0,0,0.55);

            z-index: 1500;

            opacity: 0;

            visibility: hidden;

            transition: 0.3s;

        }



        .overlay.active {

            opacity: 1;

            visibility: visible;

        }





        /* =========================

           MAIN CONTAINER

        ========================== */



        .container {



            max-width: 1400px;



            margin: auto;



            padding: 35px;

        }





        /* =========================

           HEADER

        ========================== */



        .header {



            display: flex;



            justify-content: space-between;



            align-items: center;



            margin-bottom: 25px;

        }





        .header h1 {



            font-size: 30px;

        }





        button {



            background: #d4af37;



            border: none;



            padding: 12px 20px;



            border-radius: 6px;



            font-weight: bold;



            cursor: pointer;



            transition: 0.3s;

        }





        button:hover {



            background: #f4b942;



            transform: translateY(-1px);

        }





        /* =========================

           FORM

        ========================== */



        .form {



            display: none;



            background: #0b2239;



            padding: 25px;



            border-radius: 10px;



            margin-bottom: 30px;



            box-shadow:

                0 10px 30px rgba(0,0,0,0.20);

        }





        .form h2 {



            color: #d4af37;



            margin-bottom: 20px;

        }





        .grid {



            display: grid;



            grid-template-columns:

                repeat(2,1fr);



            gap: 18px;

        }





        label {



            display: block;



            margin-bottom: 7px;



            font-weight: bold;

        }





        input,

        select {



            width: 100%;



            padding: 12px;



            border: none;



            border-radius: 5px;



            font-size: 14px;



            outline: none;

        }





        input:focus,

        select:focus {



            box-shadow:

                0 0 0 2px #d4af37;

        }





        input[readonly] {



            background: #dfe5ea;



            color: #333;



            cursor: not-allowed;

        }





        .save {



            margin-top: 20px;



            min-width: 130px;

        }





        /* =========================

           MESSAGE

        ========================== */



        .message {



            background: #163b55;



            border-left:

                4px solid #d4af37;



            padding: 12px;



            margin-bottom: 20px;



            border-radius: 6px;

        }





        /* =========================

           TABLE

        ========================== */



        table {



            width: 100%;



            border-collapse: collapse;



            background: #0b2239;



            border-radius: 10px;



            overflow: hidden;

        }





        th {



            background: #102f4d;



            color: #d4af37;



            padding: 15px;



            text-align: left;



            white-space: nowrap;

        }





        td {



            padding: 15px;



            border-bottom:

                1px solid

                rgba(255,255,255,.08);



            white-space: nowrap;

        }





        tr:hover td {



            background:

                rgba(255,255,255,0.03);

        }





        /* =========================

           RESPONSIVE

        ========================== */



        @media(max-width: 900px) {



            .grid {



                grid-template-columns: 1fr;

            }



            .container {



                padding: 20px;

            }



            .navbar {



                padding: 0 20px;

            }



            table {



                display: block;



                overflow-x: auto;

            }

        }

        /* =========================

   LOCATION MAP

\========================= */



.location-field {

    display: flex;

    gap: 8px;

}



.location-field input {

    flex: 1;

}



.map-btn {

    width: 95px;

    padding: 12px 10px;

    background: #d4af37;

    color: #0b2239;

    border: none;

    border-radius: 5px;

    font-weight: bold;

    cursor: pointer;

}



.map-btn:hover {

    background: #f4b942;

}





/* =========================

   MAP MODAL

\========================= */



.map-modal {

    display: none;



    position: fixed;



    top: 0;

    left: 0;



    width: 100%;

    height: 100%;



    background: rgba(0,0,0,0.65);



    z-index: 5000;



    align-items: center;

    justify-content: center;

}



.map-modal.active {

    display: flex;

}



.map-box {

    width: 90%;

    max-width: 850px;



    background: #0b2239;



    border-radius: 12px;



    padding: 20px;



    box-shadow:

        0 15px 50px rgba(0,0,0,0.5);

}



.map-header {

    display: flex;



    justify-content: space-between;

    align-items: center;



    margin-bottom: 15px;

}



.map-header h2 {

    color: #d4af37;



    font-size: 20px;

}



.map-close {

    background: transparent;



    color: white;



    font-size: 25px;



    padding: 5px 10px;

}



.map-close:hover {

    background: transparent;



    color: #f4b942;

}



\#locationMap {

    width: 100%;

    height: 450px;



    border-radius: 8px;



    overflow: hidden;

}



.selected-location {

    margin-top: 15px;



    padding: 12px;



    background: rgba(255,255,255,0.08);



    border-radius: 6px;



    color: white;

}



.confirm-location {

    margin-top: 15px;



    width: 100%;



    background: #d4af37;



    color: #0b2239;



    font-weight: bold;

}



@media(max-width: 600px) {



    .map-box {

        width: 95%;

        padding: 12px;

    }



    #locationMap {

        height: 350px;

    }



    .location-field {

        flex-direction: column;

    }



    .map-btn {

        width: 100%;

    }

}



    </style>

<link

    rel="stylesheet"

    href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"

/>



<script

    src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js">

</script>

</head>





<body>





<!-- =========================

     SIDEBAR

\========================== -->



<div class="sidebar" id="sidebar">



    <div class="sidebar-header">



        <div class="sidebar-title">



            MANJARE



            <span>TOURS & TRAVELS</span>



        </div>





        <button class="close-btn"

                onclick="closeSidebar()">



            ×



        </button>



    </div>





    <ul class="sidebar-menu">



        <li>

            <a href="dashboard.jsp">

                <span class="sidebar-icon">🏠</span>

                Dashboard

            </a>

        </li>





        <li>

            <a href="vehicles.jsp">

                <span class="sidebar-icon">🚗</span>

                Vehicles

            </a>

        </li>





        <li>

            <a href="drivers.jsp">

                <span class="sidebar-icon">👨‍✈️</span>

                Drivers

            </a>

        </li>





        <li>

            <a href="customers.jsp">

                <span class="sidebar-icon">🧳</span>

                Customers

            </a>

        </li>





        <li>

            <a href="trips.jsp">

                <span class="sidebar-icon">🛣️</span>

                Trips

            </a>

        </li>





        <li>

            <a href="expenses.jsp">

                <span class="sidebar-icon">💰</span>

                Expenses

            </a>

        </li>





        <li>

            <a href="payments.jsp">

                <span class="sidebar-icon">💳</span>

                Payments

            </a>

        </li>





        <li>

            <a href="reports.jsp">

                <span class="sidebar-icon">📊</span>

                Reports

            </a>

        </li>



        <li>

                <a href="maintenance.jsp">

                    <span class="sidebar-icon">🔧</span>

                    Vehicle Maintenance

                </a>

            </li>



    </ul>



</div>





<!-- SIDEBAR OVERLAY -->



<div class="overlay"

     id="overlay"

     onclick="closeSidebar()">

</div>







<!-- =========================

     NAVBAR

\========================== -->



<div class="navbar">



    <div class="nav-left">





        <!-- HAMBURGER -->



        <button

            class="menu-btn"

            onclick="openSidebar()">



            <span></span>



            <span></span>



            <span></span>



        </button>







        <!-- LOGO -->



        <div class="logo">



            MANJARE



            <span>

                TOURS & TRAVELS

            </span>



        </div>



    </div>







    <a

        href="dashboard.jsp"

        class="back">



        ← Dashboard



    </a>



</div>







<!-- =========================

     MAIN CONTAINER

\========================== -->



<div class="container">





    <!-- =========================

         PAGE HEADER

    ========================== -->



    <div class="header">



        <h1>

            🚌 Trips

        </h1>





        <button

            onclick="showForm()">



            + Add Trip



        </button>



    </div>







    <!-- =========================

         SUCCESS / ERROR MESSAGE

    ========================== -->



    <%



        if ("added".equals(

                request.getParameter("success"))) {



    %>



        <div class="message">



            Trip added successfully.

            WhatsApp message is being opened...



        </div>



    <%



        }





        if ("updated".equals(request.getParameter("success"))) {
    %>
        <div class="message">Trip updated successfully.</div>
    <%
        }

        if ("deleted".equals(request.getParameter("success"))) {
    %>
        <div class="message">Trip deleted successfully.</div>
    <%
        }

        if ("database".equals(

                request.getParameter("error"))) {



    %>



        <div class="message">



            Unable to save trip.



        </div>



    <%



        }





        if ("nowhatsapp".equals(

                request.getParameter("error"))) {



    %>



        <div class="message">



            Trip saved successfully,

            but customer WhatsApp number

            was not available.



        </div>



    <%



        }



    %>







    <!-- =========================

         ADD TRIP FORM

    ========================== -->



    <div

        class="form"

        id="tripForm">





        <h2 id="tripFormHeading">

            Add Trip

        </h2>





        <form

            action="TripServlet"

            method="post">

            <input type="hidden" name="operation" id="tripOperation" value="add">
            <input type="hidden" name="tripId" id="tripId" value="">





            <div class="grid">





                <!-- =========================

                     CUSTOMER

                ========================== -->



                <div>



                    <label>

                        Customer

                    </label>





                    <select

                        name="customerId"

                        id="customerId"

                        required

                        onchange="showCustomerMobile()">





                        <option value="">



                            Select Customer



                        </option>





                        <%



                            try {



                                Connection con =

                                    DBConnection.getConnection();





                                PreparedStatement ps =

                                    con.prepareStatement(

                                        "SELECT customer_id, name, mobile " +

                                        "FROM customers " +

                                        "ORDER BY customer_id DESC"

                                    );





                                ResultSet rs =

                                    ps.executeQuery();





                                while(rs.next()) {



                        %>





                        <option

                            value="<%= rs.getInt("customer_id") %>"

                            data-mobile="<%= rs.getString("mobile") == null ? "" : rs.getString("mobile") %>">



                            <%= rs.getString("name") %>



                        </option>





                        <%



                                }



                                rs.close();



                                ps.close();



                                con.close();



                            }



                            catch(Exception e) {



                        %>



                            <option disabled>



                                Unable to load customers



                            </option>



                        <%



                            }



                        %>



                    </select>



                </div>







                <!-- =========================

                     WHATSAPP NUMBER

                ========================== -->



                <div>



                    <label>

                        WhatsApp Number

                    </label>





                    <input

                        type="text"

                        id="customerMobile"

                        name="customerMobile"

                        placeholder="Customer WhatsApp number"

                        readonly>



                </div>







                <!-- =========================

                     VEHICLE

                ========================== -->



                <div>



                    <label>

                        Vehicle

                    </label>





                    <select

                        name="vehicleId"
                        id="vehicleId"
                        required>





                        <option value="">



                            Select Vehicle



                        </option>





                        <%



                            try {



                                Connection con =

                                    DBConnection.getConnection();





                                PreparedStatement ps =

                                    con.prepareStatement(

                                        "SELECT vehicle_id, vehicle_number " +

                                        "FROM vehicles " +

                                        "ORDER BY vehicle_id DESC"

                                    );





                                ResultSet rs =

                                    ps.executeQuery();





                                while(rs.next()) {



                        %>





                        <option

                            value="<%= rs.getInt("vehicle_id") %>">



                            <%= rs.getString("vehicle_number") %>



                        </option>





                        <%



                                }



                                rs.close();



                                ps.close();



                                con.close();



                            }



                            catch(Exception e) {



                        %>



                            <option disabled>



                                Unable to load vehicles



                            </option>



                        <%



                            }



                        %>



                    </select>



                </div>







                <!-- =========================

                     DRIVER

                ========================== -->



                <div>



                    <label>

                        Driver

                    </label>





                    <select

                        name="driverId"
                        id="driverId"
                        required>





                        <option value="">



                            Select Driver



                        </option>





                        <%



                            try {



                                Connection con =

                                    DBConnection.getConnection();





                                PreparedStatement ps =

                                    con.prepareStatement(

                                        "SELECT driver_id, name " +

                                        "FROM drivers " +

                                        "ORDER BY driver_id DESC"

                                    );





                                ResultSet rs =

                                    ps.executeQuery();





                                while(rs.next()) {



                        %>





                        <option

                            value="<%= rs.getInt("driver_id") %>">



                            <%= rs.getString("name") %>



                        </option>





                        <%



                                }



                                rs.close();



                                ps.close();



                                con.close();



                            }



                            catch(Exception e) {



                        %>



                            <option disabled>



                                Unable to load drivers



                            </option>



                        <%



                            }



                        %>



                    </select>



                </div>







                <!-- =========================

                     TRIP TYPE

                ========================== -->



                <div>



                    <label>

                        Trip Type

                    </label>





                    <select

                        name="tripType"
                        id="tripType"
                        required>





                        <option value="One Way">

                            One Way

                        </option>



                        <option value="Round Trip">

                            Round Trip

                        </option>



                        <option value="Local">

                            Local

                        </option>



                        <option value="Outstation">

                            Outstation

                        </option>



                    </select>



                </div>







                <!-- =========================

                     PICKUP

                ========================== -->



                <div>



    <label>

        Pickup

    </label>



    <div class="location-field">



        <input

            type="text"

            id="pickup"

            name="pickup"

            placeholder="Pickup location"

            required>



        <button

            type="button"

            class="map-btn"

            onclick="openMap('pickup')">



            📍 Map



        </button>



    </div>



</div>







                <!-- =========================

                     DESTINATION

                ========================== -->



                <div>



    <label>

        Destination

    </label>



    <div class="location-field">



        <input

            type="text"

            id="destination"

            name="destination"

            placeholder="Destination"

            required>



        <button

            type="button"

            class="map-btn"

            onclick="openMap('destination')">



            📍 Map



        </button>



    </div>



</div>







                <!-- =========================

                     START DATE

                ========================== -->



                <div>



                    <label>

                        Start Date

                    </label>





                    <input

                        type="date"

                        name="startDate"
                        id="startDate"
                        required>



                </div>







                <!-- =========================

                     END DATE

                ========================== -->



                <div>



                    <label>

                        End Date

                    </label>





                    <input

                        type="date"

                        name="endDate"
                        id="endDate">



                </div>







                <!-- =========================

                     FARE

                ========================== -->



                <div>



                    <label>

                        Fare

                    </label>





                    <input

                        type="number"

                        name="fare"
                        id="fare"
                        step="0.01"

                        min="0"

                        placeholder="Trip fare"

                        required>



                </div>







                <!-- =========================

                     STATUS

                ========================== -->



                <div>



                    <label>

                        Status

                    </label>





                    <select

                        name="status"
                        id="tripStatus">





                        <option value="Pending">

                            Pending

                        </option>





                        <option value="Confirmed">

                            Confirmed

                        </option>





                        <option value="Completed">

                            Completed

                        </option>





                        <option value="Cancelled">

                            Cancelled

                        </option>





                    </select>



                </div>



            </div>







            <!-- =========================

                 SAVE BUTTON

            ========================== -->



            <button

                type="submit"

                class="save"
                id="tripSubmitButton">



                Save Trip



            </button>



        </form>



    </div>







    <!-- =========================

         TRIPS TABLE

    ========================== -->



    <table>





        <tr>



            <th>

                ID

            </th>



            <th>

                Customer

            </th>



            <th>

                Vehicle

            </th>



            <th>

                Driver

            </th>



            <th>

                Route

            </th>



            <th>

                Dates

            </th>



            <th>

                Fare

            </th>



            <th>

                Status

            </th>

            <th>

                Actions

            </th>



        </tr>







        <%



            try {



                Connection con =

                    DBConnection.getConnection();





                String sql =



                    "SELECT t.trip_id, " +



                    "t.customer_id, t.vehicle_id, t.driver_id, t.trip_type, " +

                    "c.name AS customer_name, " +



                    "v.vehicle_number, " +



                    "d.name AS driver_name, " +



                    "t.pickup, " +

                    "t.destination, " +



                    "t.start_date, " +

                    "t.end_date, " +



                    "t.fare, " +

                    "t.status " +



                    "FROM trips t " +



                    "LEFT JOIN customers c " +



                    "ON t.customer_id = c.customer_id " +



                    "LEFT JOIN vehicles v " +



                    "ON t.vehicle_id = v.vehicle_id " +



                    "LEFT JOIN drivers d " +



                    "ON t.driver_id = d.driver_id " +



                    "ORDER BY t.trip_id DESC";





                PreparedStatement ps =

                    con.prepareStatement(sql);





                ResultSet rs =

                    ps.executeQuery();





                while(rs.next()) {



        %>





        <tr>





            <td>



                <%= rs.getInt("trip_id") %>



            </td>





            <td>



                <%= rs.getString("customer_name") %>



            </td>





            <td>



                <%= rs.getString("vehicle_number") %>



            </td>





            <td>



                <%= rs.getString("driver_name") %>



            </td>





            <td>



                <%= rs.getString("pickup") %>



                →



                <%= rs.getString("destination") %>



            </td>





            <td>



                <%= rs.getDate("start_date") %>



                -



                <%= rs.getDate("end_date") %>



            </td>





            <td>



                ₹<%= rs.getDouble("fare") %>



            </td>





            <td>



                <%= rs.getString("status") %>



            </td>

            <td>

                <button type="button" class="trip-edit" onclick="editTrip(this)"
                    data-trip-id="<%= rs.getInt("trip_id") %>"
                    data-customer-id="<%= rs.getInt("customer_id") %>"
                    data-vehicle-id="<%= rs.getInt("vehicle_id") %>"
                    data-driver-id="<%= rs.getInt("driver_id") %>"
                    data-trip-type="<%= escapeTripAttribute(rs.getString("trip_type")) %>"
                    data-pickup="<%= escapeTripAttribute(rs.getString("pickup")) %>"
                    data-destination="<%= escapeTripAttribute(rs.getString("destination")) %>"
                    data-start-date="<%= rs.getDate("start_date") == null ? "" : rs.getDate("start_date").toString() %>"
                    data-end-date="<%= rs.getDate("end_date") == null ? "" : rs.getDate("end_date").toString() %>"
                    data-fare="<%= rs.getDouble("fare") %>"
                    data-status="<%= escapeTripAttribute(rs.getString("status")) %>">Edit</button>

                <form action="TripServlet" method="post" style="display:inline; margin-left:6px;"
                    onsubmit="return confirm('Are you sure you want to delete this trip? Related payment records will also be deleted.');">
                    <input type="hidden" name="operation" value="delete">
                    <input type="hidden" name="tripId" value="<%= rs.getInt("trip_id") %>">
                    <button type="submit" style="background:#c0392b; color:white; padding:10px 14px;">Delete</button>
                </form>

            </td>





        </tr>





        <%



                }



                rs.close();



                ps.close();



                con.close();



            }



            catch(Exception e) {



        %>





        <tr>



            <td colspan="9">



                Database Error:



                <%= e.getMessage() %>



            </td>



        </tr>





        <%



            }



        %>





    </table>





</div>



<!-- =========================

     LOCATION MAP MODAL

\========================= -->



<div

    class="map-modal"

    id="mapModal">



    <div class="map-box">



        <div class="map-header">



            <h2 id="mapTitle">

                Select Location

            </h2>



            <button

                type="button"

                class="map-close"

                onclick="closeMap()">



                ✕



            </button>



        </div>





        <div id="locationMap"></div>





        <div

            class="selected-location"

            id="selectedLocation">



            Click anywhere on the map

            to select a location.



        </div>





        <button

            type="button"

            class="confirm-location"

            onclick="confirmLocation()">



            Confirm Location



        </button>



    </div>



</div>



<!-- =========================

     JAVASCRIPT

\========================== -->



<script>





/* =========================

   SHOW / HIDE FORM

\========================= */



function showForm() {

    const form = document.getElementById("tripForm");

    if (form.style.display === "block") {
        form.style.display = "none";
    } else {
        resetTripForm();
        form.style.display = "block";
        form.scrollIntoView({ behavior: "smooth", block: "start" });
    }

}

function resetTripForm() {
    document.getElementById("tripOperation").value = "add";
    document.getElementById("tripId").value = "";
    document.getElementById("tripFormHeading").textContent = "Add Trip";
    document.getElementById("tripSubmitButton").textContent = "Save Trip";
    document.getElementById("customerId").value = "";
    document.getElementById("vehicleId").value = "";
    document.getElementById("driverId").value = "";
    document.getElementById("tripType").value = "One Way";
    document.getElementById("pickup").value = "";
    document.getElementById("destination").value = "";
    document.getElementById("startDate").value = "";
    document.getElementById("endDate").value = "";
    document.getElementById("fare").value = "";
    document.getElementById("tripStatus").value = "Pending";
    if (typeof showCustomerMobile === "function") showCustomerMobile();
}

function editTrip(button) {
    resetTripForm();
    document.getElementById("tripOperation").value = "update";
    document.getElementById("tripId").value = button.dataset.tripId;
    document.getElementById("tripFormHeading").textContent = "Edit Trip #" + button.dataset.tripId;
    document.getElementById("tripSubmitButton").textContent = "Update Trip";
    document.getElementById("customerId").value = button.dataset.customerId;
    document.getElementById("vehicleId").value = button.dataset.vehicleId;
    document.getElementById("driverId").value = button.dataset.driverId;
    document.getElementById("tripType").value = button.dataset.tripType;
    document.getElementById("pickup").value = button.dataset.pickup;
    document.getElementById("destination").value = button.dataset.destination;
    document.getElementById("startDate").value = button.dataset.startDate;
    document.getElementById("endDate").value = button.dataset.endDate;
    document.getElementById("fare").value = button.dataset.fare;
    document.getElementById("tripStatus").value = button.dataset.status;
    if (typeof showCustomerMobile === "function") showCustomerMobile();
    const form = document.getElementById("tripForm");
    form.style.display = "block";
    form.scrollIntoView({ behavior: "smooth", block: "start" });
}







/* =========================

   OPEN SIDEBAR

\========================= */



function openSidebar() {



    document

        .getElementById("sidebar")

        .classList

        .add("active");





    document

        .getElementById("overlay")

        .classList

        .add("active");



}







/* =========================

   CLOSE SIDEBAR

\========================= */



function closeSidebar() {



    document

        .getElementById("sidebar")

        .classList

        .remove("active");





    document

        .getElementById("overlay")

        .classList

        .remove("active");



}







/* =========================

   SHOW CUSTOMER MOBILE

\========================= */



function showCustomerMobile() {



    const customerSelect =

        document.getElementById("customerId");





    const mobileInput =

        document.getElementById("customerMobile");





    const selectedOption =

        customerSelect.options[

            customerSelect.selectedIndex

        ];





    if(selectedOption.value !== "") {



        mobileInput.value =

            selectedOption.getAttribute(

                "data-mobile"

            ) || "";



    }



    else {



        mobileInput.value = "";



    }



}







/* =========================

   AUTOMATIC WHATSAPP OPEN

\========================= */



window.addEventListener(

    "load",

    function() {



        const urlParams =

            new URLSearchParams(

                window.location.search

            );





        const whatsappUrl =

            urlParams.get("whatsapp");





        if(whatsappUrl) {



            /*

             * Open WhatsApp automatically

             * after successful database save.

             */



            window.open(

                whatsappUrl,

                "_blank"

            );





            /*

             * Remove WhatsApp URL from

             * browser address bar.

             */



            window.history.replaceState(

                {},

                document.title,

                "trips.jsp?success=added"

            );



        }



    }

);

/* =========================

   LOCATION MAP

\========================= */



let map = null;



let marker = null;



let currentLocationField = null;



let selectedLatitude = null;



let selectedLongitude = null;

let selectedAddress = "";



/* =========================

   OPEN MAP

\========================= */



function openMap(field) {



    currentLocationField = field;



    const modal =

        document.getElementById("mapModal");



    const title =

        document.getElementById("mapTitle");



    if (field === "pickup") {



        title.innerText =

            "Select Pickup Location";



    } else {



        title.innerText =

            "Select Destination";



    }



    modal.classList.add("active");





    /*

     * Create map only once.

     */



    if (map === null) {



        map = L.map("locationMap")

            .setView(

                [19.0760, 72.8777],

                10

            );





        L.tileLayer(

            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",

            {

                attribution:

                    '&copy; OpenStreetMap contributors'

            }

        ).addTo(map);





        /*

         * When user clicks map

         */



        map.on(

            "click",

            function(e) {



                selectLocation(

                    e.latlng.lat,

                    e.latlng.lng

                );



            }

        );



    }





    /*

     * Important:

     * Leaflet needs this when

     * the map is inside a hidden modal.

     */



    setTimeout(

        function() {



            map.invalidateSize();



        },

        200

    );



}





/* =========================

   SELECT LOCATION

\========================= */



async function selectLocation(latitude, longitude) {



    selectedLatitude = latitude;

    selectedLongitude = longitude;



    // Remove previous marker

    if (marker !== null) {

        map.removeLayer(marker);

    }



    // Add new marker

    marker = L.marker([

        latitude,

        longitude

    ]).addTo(map);



    // Show loading message

    document

        .getElementById("selectedLocation")

        .innerText = "Finding address...";



    try {



        const response = await fetch(

            "https://nominatim.openstreetmap.org/reverse"

            + "?format=jsonv2"

            + "&lat=" + encodeURIComponent(latitude)

            + "&lon=" + encodeURIComponent(longitude)

            + "&addressdetails=1"

        );



        if (!response.ok) {

            throw new Error("Unable to find address");

        }



        const data = await response.json();



        const address =

            data.display_name;



        if (address) {



            document

                .getElementById("selectedLocation")

                .innerText =

                    address;



            // Store readable address temporarily

            selectedAddress = address;



        } else {



            document

                .getElementById("selectedLocation")

                .innerText =

                    "Address not found. Please try another location.";



            selectedAddress = "";



        }



    } catch (error) {



        console.error(error);



        document

            .getElementById("selectedLocation")

            .innerText =

                "Could not find the address. Please try again.";



        selectedAddress = "";



    }

}





/* =========================

   CONFIRM LOCATION

\========================= */



function confirmLocation() {



    if (

        selectedLatitude === null ||

        selectedLongitude === null

    ) {



        alert(

            "Please select a location on the map first."

        );



        return;



    }





    /*

     * For the first version,

     * save coordinates into the

     * existing address field.

     */



    if (!selectedAddress) {



    alert(

        "Please select a location and wait for the address to load."

    );



    return;

}



document

    .getElementById(currentLocationField)

    .value = selectedAddress;



    closeMap();



}





/* =========================

   CLOSE MAP

\========================= */



function closeMap() {



    document

        .getElementById(

            "mapModal"

        )

        .classList

        .remove("active");



}

</script>





</body>



</html>