<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Forgot Password</title>

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #0f172a;
            color: white;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .container {
            width: 400px;
            padding: 35px;
            background: #1e293b;
            border-radius: 15px;
        }

        input {
            width: 100%;
            padding: 12px;
            margin: 8px 0 15px;
            box-sizing: border-box;
        }

        button {
            width: 100%;
            padding: 12px;
            background: #2563eb;
            color: white;
            border: none;
            cursor: pointer;
        }

        .error {
            background: #7f1d1d;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 8px;
        }

        .success {
            background: #166534;
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 8px;
        }
    </style>
</head>

<body>

<div class="container">

    <h2>Forgot Password</h2>

    <%
        String error = request.getParameter("error");

        if ("empty".equals(error)) {
    %>
        <div class="error">
            Phone number or email is empty.
        </div>

    <%
        } else if ("invalid".equals(error)) {
    %>
        <div class="error">
            Phone number and email do not match any user.
        </div>

    <%
        } else if ("database".equals(error)) {
    %>
        <div class="error">
            Database error occurred.
        </div>

    <%
        } else if ("email".equals(error)) {
    %>
        <div class="error">
            User was found, but the OTP email could not be sent.
            Check your Gmail/App Password settings.
        </div>
    <%
        }
    %>


    <form action="ForgotPasswordServlet" method="post">

        <label>Phone Number</label>

        <input
            type="tel"
            name="phone"
            placeholder="Enter phone number"
            required
        >


        <label>Email Address</label>

        <input
            type="email"
            name="email"
            placeholder="Enter email address"
            required
        >


        <button type="submit">
            VERIFY DETAILS
        </button>

    </form>

</div>

</body>
</html>