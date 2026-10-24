<%@ page import="java.sql.*" %>
<%@ page import="com.manjare.DBConnection" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    String tripIdParam = request.getParameter("tripId");

    int tripId = 0;

    if (tripIdParam != null && !tripIdParam.isEmpty()) {
        try {
            tripId = Integer.parseInt(tripIdParam);
        } catch (NumberFormatException e) {
            tripId = 0;
        }
    }

    String customerName = "";
    String customerMobile = "";
    String pickup = "";
    String destination = "";
    String startDate = "";
    String endDate = "";
    String tripType = "";
    String tripStatus = "";

    double fare = 0.0;

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {

        con = DBConnection.getConnection();

        String sql =
            "SELECT t.trip_id, " +
            "c.name AS customer_name, " +
            "c.mobile AS customer_mobile, " +
            "t.trip_type, " +
            "t.pickup, " +
            "t.destination, " +
            "t.start_date, " +
            "t.end_date, " +
            "t.fare, " +
            "t.status " +
            "FROM trips t " +
            "LEFT JOIN customers c ON t.customer_id = c.customer_id " +
            "WHERE t.trip_id = ?";

        ps = con.prepareStatement(sql);

        ps.setInt(1, tripId);

        rs = ps.executeQuery();

        if (rs.next()) {

            customerName = rs.getString("customer_name");
            customerMobile = rs.getString("customer_mobile");
            tripType = rs.getString("trip_type");

            pickup = rs.getString("pickup");
            destination = rs.getString("destination");

            startDate = rs.getString("start_date");
            endDate = rs.getString("end_date");

            fare = rs.getDouble("fare");

            tripStatus = rs.getString("status");

        } else {

            tripId = 0;
        }

    } catch (Exception e) {

        e.printStackTrace();

    } finally {

        try {
            if (rs != null) rs.close();
        } catch (Exception ignored) {}

        try {
            if (ps != null) ps.close();
        } catch (Exception ignored) {}

        try {
            if (con != null) con.close();
        } catch (Exception ignored) {}
    }


    /*
     * UPI PAYMENT INFORMATION
     */

    String upiId = "8291718981@fam";

    String upiPaymentString =
        "upi://pay" +
        "?pa=" + upiId +
        "&pn=MANJARE%20TOURS%20%26%20TRAVELS" +
        "&am=" + String.format("%.2f", fare) +
        "&cu=INR";

    String encodedUPI =
        URLEncoder.encode(upiPaymentString, "UTF-8");

    String qrUrl =
        "https://api.qrserver.com/v1/create-qr-code/" +
        "?size=300x300&data=" +
        encodedUPI;
%>


<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Payment | Manjare Tours & Travels
    </title>


    <style>

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }


        body {

            background: #0b1220;

            color: white;

            min-height: 100vh;

            padding: 40px;
        }


        .container {

            max-width: 900px;

            margin: auto;
        }


        /* HEADER */

        .header {

            text-align: center;

            margin-bottom: 30px;
        }


        .header h1 {

            color: #f4b942;

            margin-bottom: 8px;

            font-size: 30px;
        }


        .header p {

            color: #aaa;

            font-size: 15px;
        }


        /* PAYMENT BOX */

        .payment-box {

            background: #121c2e;

            border-radius: 15px;

            padding: 30px;

            box-shadow:
                0 10px 30px rgba(0,0,0,0.3);
        }


        /* TRIP INFORMATION */

        .trip-info {

            display: grid;

            grid-template-columns: 1fr 1fr;

            gap: 15px;

            margin-bottom: 30px;
        }


        .info {

            background: #1a263a;

            padding: 15px;

            border-radius: 10px;
        }


        .label {

            color: #999;

            font-size: 13px;

            margin-bottom: 6px;
        }


        .value {

            font-size: 16px;

            font-weight: bold;

            word-break: break-word;
        }


        /* AMOUNT */

        .amount-box {

            text-align: center;

            background: #1a263a;

            padding: 25px;

            border-radius: 12px;

            margin-bottom: 30px;
        }


        .amount-box p {

            color: #aaa;

            margin-bottom: 8px;

            font-size: 15px;
        }


        .amount {

            color: #f4b942;

            font-size: 40px;

            font-weight: bold;
        }


        /* QR SECTION */

        .qr-section {

            text-align: center;

            margin-top: 25px;
        }


        .qr-section h2 {

            margin-bottom: 10px;

            font-size: 24px;
        }


        .qr-section p {

            color: #aaa;

            margin-bottom: 20px;
        }


        /* QR IMAGE */

        .qr-image {

            width: 300px;

            height: 300px;

            background: white;

            padding: 10px;

            border-radius: 12px;

            display: block;

            margin: 0 auto 20px auto;

            box-shadow:
                0 5px 20px rgba(0,0,0,0.4);
        }


        /* UPI DETAILS */

        .upi-details {

            background: #1a263a;

            padding: 15px;

            border-radius: 10px;

            max-width: 400px;

            margin: 0 auto;

            text-align: center;
        }


        .upi-details .label {

            margin-bottom: 7px;
        }


        .upi-id {

            color: #f4b942;

            font-weight: bold;

            font-size: 16px;

            word-break: break-all;
        }


        /* PAY NOW BUTTON */

        .pay-now-btn {

            display: block;

            width: 230px;

            margin: 25px auto 0 auto;

            padding: 14px 20px;

            background: #20c55a;

            color: white;

            text-decoration: none;

            text-align: center;

            border-radius: 8px;

            font-size: 17px;

            font-weight: bold;

            transition: 0.2s;

            box-shadow:
                0 5px 15px rgba(0,0,0,0.25);
        }


        .pay-now-btn:hover {

            background: #18a94b;

            transform: translateY(-2px);
        }


        /* PAYMENT STATUS */

        .status {

            text-align: center;

            margin-top: 25px;

            padding: 15px;

            border-radius: 10px;

            background: #332b16;

            color: #f4b942;

            font-weight: bold;
        }


        /* NOT FOUND */

        .not-found {

            text-align: center;

            padding: 40px;
        }


        .not-found h2 {

            color: #f4b942;

            margin-bottom: 15px;
        }


        .not-found p {

            color: #aaa;
        }


        /* MOBILE */

        @media (max-width: 600px) {

            body {

                padding: 20px;
            }


            .payment-box {

                padding: 20px;
            }


            .trip-info {

                grid-template-columns: 1fr;
            }


            .header h1 {

                font-size: 24px;
            }


            .amount {

                font-size: 32px;
            }


            .qr-image {

                width: 250px;

                height: 250px;
            }

        }

    </style>

</head>


<body>


<div class="container">


    <!-- HEADER -->

    <div class="header">

        <h1>
            MANJARE TOURS &amp; TRAVELS
        </h1>

        <p>
            Secure Payment
        </p>

    </div>


<%
    if (tripId == 0) {
%>


    <!-- TRIP NOT FOUND -->

    <div class="payment-box not-found">

        <h2>
            Trip Not Found
        </h2>

        <p>
            The requested trip could not be found.
        </p>

    </div>


<%
    } else {
%>


    <!-- PAYMENT BOX -->

    <div class="payment-box">


        <!-- TRIP INFORMATION -->

        <div class="trip-info">


            <div class="info">

                <div class="label">
                    Trip ID
                </div>

                <div class="value">
                    #<%= tripId %>
                </div>

            </div>


            <div class="info">

                <div class="label">
                    Customer
                </div>

                <div class="value">
                    <%= customerName %>
                </div>

            </div>


            <div class="info">

                <div class="label">
                    Mobile
                </div>

                <div class="value">
                    <%= customerMobile %>
                </div>

            </div>


            <div class="info">

                <div class="label">
                    Trip Type
                </div>

                <div class="value">
                    <%= tripType %>
                </div>

            </div>


            <div class="info">

                <div class="label">
                    Pickup
                </div>

                <div class="value">
                    <%= pickup %>
                </div>

            </div>


            <div class="info">

                <div class="label">
                    Destination
                </div>

                <div class="value">
                    <%= destination %>
                </div>

            </div>


            <div class="info">

                <div class="label">
                    Start Date
                </div>

                <div class="value">
                    <%= startDate %>
                </div>

            </div>


            <div class="info">

                <div class="label">
                    End Date
                </div>

                <div class="value">

<%
                    if (endDate == null ||
                        endDate.equals("null") ||
                        endDate.isEmpty()) {
%>

                        Not specified

<%
                    } else {
%>

                        <%= endDate %>

<%
                    }
%>

                </div>

            </div>


        </div>


        <!-- AMOUNT -->

        <div class="amount-box">

            <p>
                Total Trip Fare
            </p>

            <div class="amount">

                &#8377;
                <%= String.format("%.2f", fare) %>

            </div>

        </div>


        <!-- QR + PAY NOW -->

        <div class="qr-section">

            <h2>
                Scan &amp; Pay
            </h2>

            <p>
                Scan the QR code using your UPI app
            </p>


            <!-- QR CODE -->

            <img
                src="<%= qrUrl %>"
                alt="UPI QR Code"
                class="qr-image"
            >


            <!-- UPI ID -->

            <div class="upi-details">

                <div class="label">
                    UPI ID
                </div>

                <div class="upi-id">
                    <%= upiId %>
                </div>

            </div>


            <!-- PAY NOW BUTTON -->

            <a
                href="<%= upiPaymentString %>"
                class="pay-now-btn"
            >

                &#8377;&nbsp; Pay Now

            </a>


        </div>


        <!-- PAYMENT STATUS -->

        <div class="status">

            Payment Status: Pending

        </div>


    </div>


<%
    }
%>


</div>


</body>

</html>