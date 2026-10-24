const passwordInput =
    document.getElementById("password");

const togglePassword =
    document.getElementById("togglePassword");

const loginForm =
    document.getElementById("loginForm");


const car =
    document.querySelector(".car");

const wheel =
    document.querySelector(".wheel");


const brandingArea =
    document.querySelector(".branding-area");

const brandingContent =
    document.querySelector(".branding-content");


const brandName =
    document.querySelector(".brand-name");

const brandSubtitle =
    document.querySelector(".brand-subtitle");

const welcomeText =
    document.querySelector(".branding-content h2");

const description =
    document.querySelector(".branding-content p");

const divider =
    document.querySelector(".divider");


let isDragging = false;

let isRevealed = false;

let startX = 0;

let currentProgress = 0;


/* =========================================================
   PASSWORD SHOW / HIDE
   ========================================================= */

if (togglePassword && passwordInput) {

    togglePassword.addEventListener(
        "click",
        function () {

            if (
                passwordInput.type === "password"
            ) {

                passwordInput.type = "text";

                togglePassword.textContent =
                    "🙈";

            } else {

                passwordInput.type =
                    "password";

                togglePassword.textContent =
                    "👁";
            }

        }
    );

}


/* =========================================================
   INITIAL VALUES
   ========================================================= */

const INITIAL_CAR_OFFSET = -200;

const DRAG_DISTANCE = 200;


/* =========================================================
   INTRO STATE
   ========================================================= */

function setIntroState() {

    document.body.classList.add(
        "intro-mode"
    );

    document.body.classList.remove(
        "revealed"
    );


    if (car) {

        car.style.transform =
            "translateX(-200px)";
    }


    if (wheel) {

        wheel.style.transform =
            "translateX(-200px)";
    }


    if (brandingArea) {

        brandingArea.style.left = "0%";

        brandingArea.style.width =
            "100%";
    }


    if (brandingContent) {

        brandingContent.style.textAlign =
            "center";
    }


    if (brandName) {

        brandName.style.fontSize =
            "42px";
    }


    if (brandSubtitle) {

        brandSubtitle.style.fontSize =
            "16px";
    }


    if (welcomeText) {

        welcomeText.style.fontSize =
            "78px";
    }


    if (description) {

        description.style.fontSize =
            "21px";
    }


    if (divider) {

        divider.style.width =
            "100px";
    }


    const loginCard =
        document.querySelector(".login-card");


    if (loginCard) {

        loginCard.style.transform =
            "translateX(-130%)";

        loginCard.style.opacity =
            "0";

        loginCard.style.pointerEvents =
            "none";
    }

}


/* =========================================================
   UPDATE ANIMATION
   ========================================================= */

function updateAnimation(progress) {

    progress =
        Math.max(
            0,
            Math.min(1, progress)
        );


    currentProgress =
        progress;


    /* CAR */

    const carX =
        INITIAL_CAR_OFFSET
        + (DRAG_DISTANCE * progress);


    if (car) {

        car.style.transform =
            `translateX(${carX}px)`;
    }


    if (wheel) {

        wheel.style.transform =
            `translateX(${carX}px)`;
    }


    /* BRANDING */

    if (brandingArea) {

        const left =
            50 * progress;

        const width =
            100 - (50 * progress);


        brandingArea.style.left =
            `${left}%`;

        brandingArea.style.width =
            `${width}%`;
    }


    /* TEXT */

    const nameSize =
        42 - (14 * progress);

    const subtitleSize =
        16 - (3 * progress);

    const welcomeSize =
        78 - (14 * progress);

    const descriptionSize =
        21 - (3 * progress);

    const dividerWidth =
        100 - (20 * progress);


    if (brandName) {

        brandName.style.fontSize =
            `${nameSize}px`;
    }


    if (brandSubtitle) {

        brandSubtitle.style.fontSize =
            `${subtitleSize}px`;
    }


    if (welcomeText) {

        welcomeText.style.fontSize =
            `${welcomeSize}px`;
    }


    if (description) {

        description.style.fontSize =
            `${descriptionSize}px`;
    }


    if (divider) {

        divider.style.width =
            `${dividerWidth}px`;
    }


    /* LOGIN CARD */

    const loginX =
        -130 + (130 * progress);


    const loginOpacity =
        progress;


    const loginCard =
        document.querySelector(".login-card");


    if (loginCard) {

        loginCard.style.transform =
            `translateX(${loginX}%)`;

        loginCard.style.opacity =
            loginOpacity;
    }


    if (brandingContent) {

        if (progress >= 0.85) {

            brandingContent.style.textAlign =
                "left";

        } else {

            brandingContent.style.textAlign =
                "center";
        }

    }

}


/* =========================================================
   START DRAG
   ========================================================= */

function startDrag(event) {

    if (isRevealed) {

        return;
    }


    isDragging = true;

    startX =
        event.clientX;


    document.body.classList.add(
        "is-dragging"
    );


    if (car) {

        car.style.cursor =
            "grabbing";
    }


    if (wheel) {

        wheel.style.cursor =
            "grabbing";
    }


    event.preventDefault();

}


/* =========================================================
   DRAG CAR
   ========================================================= */

function dragCar(event) {

    if (
        !isDragging ||
        isRevealed
    ) {

        return;
    }


    const movement =
        event.clientX - startX;


    const limitedMovement =
        Math.max(
            0,
            Math.min(
                DRAG_DISTANCE,
                movement
            )
        );


    const progress =
        limitedMovement /
        DRAG_DISTANCE;


    updateAnimation(progress);

}


/* =========================================================
   END DRAG
   ========================================================= */

function endDrag() {

    if (
        !isDragging ||
        isRevealed
    ) {

        return;
    }


    isDragging = false;


    document.body.classList.remove(
        "is-dragging"
    );


    if (
        currentProgress >= 0.55
    ) {

        revealPage();

    } else {

        updateAnimation(0);

    }


    if (car) {

        car.style.cursor =
            "grab";
    }


    if (wheel) {

        wheel.style.cursor =
            "grab";
    }

}


/* =========================================================
   REVEAL PAGE
   ========================================================= */

function revealPage() {

    isRevealed = true;

    currentProgress = 1;


    document.body.classList.remove(
        "intro-mode"
    );


    document.body.classList.add(
        "revealed"
    );


    updateAnimation(1);


    if (car) {

        car.style.transform =
            "translateX(0)";
    }


    if (wheel) {

        wheel.style.transform =
            "translateX(0)";
    }


    if (brandingArea) {

        brandingArea.style.left =
            "50%";

        brandingArea.style.width =
            "50%";
    }


    if (brandingContent) {

        brandingContent.style.textAlign =
            "left";
    }


    const loginCard =
        document.querySelector(
            ".login-card"
        );


    if (loginCard) {

        loginCard.style.transform =
            "translateX(0)";

        loginCard.style.opacity =
            "1";

        loginCard.style.pointerEvents =
            "auto";
    }

}


/* =========================================================
   POINTER EVENTS
   ========================================================= */

if (car) {

    car.addEventListener(
        "pointerdown",
        startDrag
    );

}


if (wheel) {

    wheel.addEventListener(
        "pointerdown",
        startDrag
    );

}


window.addEventListener(
    "pointermove",
    dragCar
);


window.addEventListener(
    "pointerup",
    endDrag
);


window.addEventListener(
    "pointercancel",
    endDrag
);


/* =========================================================
   INITIALIZE
   ========================================================= */

setIntroState();