<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    Boolean otpVerified =
            (Boolean) session.getAttribute("otpVerified");

    String username =
            (String) session.getAttribute("resetUsername");

    if (!Boolean.TRUE.equals(otpVerified)
            || username == null) {

        response.sendRedirect("forgotPassword.jsp?error=session");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>

    <meta charset="UTF-8">

    <title>Reset Password - Manjare Tours & Travels</title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 0;

            min-height: 100vh;

            display: flex;
            justify-content: center;
            align-items: center;

            font-family: Arial, sans-serif;

            background: linear-gradient(
                135deg,
                #0f172a,
                #1e3a8a,
                #0f172a
            );

            color: white;
        }

        .container {
            width: 400px;
            padding: 40px;

            background: rgba(255, 255, 255, 0.08);

            border: 1px solid rgba(255, 255, 255, 0.15);

            border-radius: 20px;

            backdrop-filter: blur(10px);

            box-shadow:
                0 20px 50px rgba(0, 0, 0, 0.4);

            text-align: center;
        }

        h1 {
            margin-bottom: 10px;
            font-size: 28px;
        }

        .subtitle {
            color: #cbd5e1;
            font-size: 14px;
            margin-bottom: 25px;
        }

        .input-group {
            margin-bottom: 18px;
            text-align: left;
        }

        .input-group label {
            display: block;
            margin-bottom: 7px;
            font-size: 14px;
            color: #e2e8f0;
        }

        .password-input {
            width: 100%;

            padding: 14px;

            border: none;

            border-radius: 10px;

            background: rgba(255, 255, 255, 0.95);

            color: #111827;

            font-size: 15px;

            outline: none;
        }

        .password-input:focus {
            box-shadow:
                0 0 0 3px rgba(96, 165, 250, 0.5);
        }

        .reset-button {
            width: 100%;

            margin-top: 8px;

            padding: 14px;

            border: none;

            border-radius: 10px;

            background: #2563eb;

            color: white;

            font-size: 16px;

            font-weight: bold;

            cursor: pointer;

            transition: 0.2s;
        }

        .reset-button:hover {
            background: #1d4ed8;
        }

        .error {
            margin-bottom: 20px;

            padding: 10px;

            border-radius: 8px;

            background: rgba(239, 68, 68, 0.2);

            color: #fecaca;

            font-size: 14px;
        }

        .password-note {
            margin-top: 18px;

            color: #94a3b8;

            font-size: 12px;
        }

    </style>

</head>

<body>

<div class="container">

    <h1>Reset Password</h1>

    <p class="subtitle">
        Create a new password for your account.
    </p>


    <%
        String error = request.getParameter("error");

        if ("mismatch".equals(error)) {
    %>

        <div class="error">
            Passwords do not match. Please try again.
        </div>

    <%
        } else if ("empty".equals(error)) {
    %>

        <div class="error">
            Please enter both password fields.
        </div>

    <%
        } else if ("failed".equals(error)) {
    %>

        <div class="error">
            Password update failed. Please try again.
        </div>

    <%
        }
    %>


    <form action="ResetPasswordServlet" method="post">

        <div class="input-group">

            <label for="newPassword">
                New Password
            </label>

            <input
                type="password"
                id="newPassword"
                name="newPassword"
                class="password-input"
                placeholder="Enter new password"
                required
            >

        </div>


        <div class="input-group">

            <label for="confirmPassword">
                Confirm Password
            </label>

            <input
                type="password"
                id="confirmPassword"
                name="confirmPassword"
                class="password-input"
                placeholder="Confirm new password"
                required
            >

        </div>


        <button
            type="submit"
            class="reset-button">
            RESET PASSWORD
        </button>

    </form>


    <div class="password-note">
        Make sure you remember your new password.
    </div>

</div>

</body>
</html>