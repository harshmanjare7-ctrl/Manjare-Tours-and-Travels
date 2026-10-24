<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Verify OTP - Manjare Tours & Travels</title>

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
            margin-bottom: 30px;
        }

        .otp-input {
            width: 100%;

            padding: 15px;

            border: none;

            border-radius: 10px;

            background: rgba(255, 255, 255, 0.95);

            color: #111827;

            font-size: 22px;

            text-align: center;

            letter-spacing: 8px;

            outline: none;
        }

        .otp-input:focus {
            box-shadow: 0 0 0 3px rgba(96, 165, 250, 0.5);
        }

        .verify-button {
            width: 100%;

            margin-top: 20px;

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

        .verify-button:hover {
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

        .back-login {
            display: inline-block;

            margin-top: 20px;

            color: #93c5fd;

            text-decoration: none;

            font-size: 14px;
        }

        .back-login:hover {
            text-decoration: underline;
        }

    </style>
</head>

<body>

<div class="container">

    <h1>Verify OTP</h1>

    <p class="subtitle">
        Enter the 6-digit OTP sent to your registered email address.
    </p>


    <% 
        String error = request.getParameter("error");

        if ("invalid".equals(error)) {
    %>

        <div class="error">
            Invalid OTP. Please check the code and try again.
        </div>

    <%
        } else if ("expired".equals(error)) {
    %>

        <div class="error">
            Your OTP has expired. Please request a new OTP.
        </div>

    <%
        } else if ("session".equals(error)) {
    %>

        <div class="error">
            Your password reset session has expired. Please start again.
        </div>

    <%
        }
    %>


    <form action="VerifyOtpServlet" method="post">

        <input
            type="text"
            name="otp"
            class="otp-input"
            placeholder="------"
            maxlength="6"
            pattern="[0-9]{6}"
            inputmode="numeric"
            autocomplete="one-time-code"
            required
        >

        <button
            type="submit"
            class="verify-button">
            VERIFY OTP
        </button>

    </form>


    <a href="forgotPassword.jsp" class="back-login">
        ← Back
    </a>

</div>

</body>
</html>