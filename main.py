# om shree ganeshaye namah 🕉️
from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
app.secret_key = "super_secret_key"  # For session handling

# -------------------- DB Connection --------------------
mydb = mysql.connector.connect(
    host="localhost",
    user="root",
    password="BUbs3456@",
    database="globe_trotter1"
)
cursor = mydb.cursor()

# -------------------- ROUTES --------------------

@app.route('/')
def first():
    return render_template('screen1.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == "POST":
        first_name = request.form["name"]  # Match form's "name" field
        email = request.form["email"]
        password = request.form["password"]
        confirm_password = request.form["confirm_password"]

        if password != confirm_password:
            flash("Passwords do not match!", "error")
            return redirect(url_for("register"))

        hashed_password = generate_password_hash(password)

        try:
            cursor.execute(
                """
                INSERT INTO users (first_name, email, password_hash)
                VALUES (%s, %s, %s)
                """,
                (first_name, email, hashed_password)
            )
            mydb.commit()
            flash("Registration successful! Please log in.", "success")
            return redirect(url_for("login"))
        except mysql.connector.IntegrityError:
            flash("Email already exists!", "error")
            return redirect(url_for("register"))

    return render_template('screen2.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == "POST":
        email = request.form["email"]
        password = request.form["password"]

        cursor.execute("SELECT id, name, password_hash FROM users WHERE email=%s", (email,))
        user = cursor.fetchone()

        if user and check_password_hash(user[2], password):
            session["user_id"] = user[0]
            session["user_name"] = user[1]
            flash("Login successful!", "success")
            return redirect(url_for("profile"))
        else:
            flash("Invalid email or password.", "error")
            return redirect(url_for("login"))

    return render_template('screen3.html')

@app.route('/forgot-password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == "POST":
        email = request.form["email"]
        # Add logic to send reset link or OTP here
        flash("If this email exists, a reset link has been sent.", "info")
        return redirect(url_for("login"))
    return render_template('forgot_password.html')

@app.route('/logout')
def logout():
    session.clear()
    flash("You have been logged out.", "info")
    return redirect(url_for("first"))

@app.route('/profile')
def profile():
    if "user_id" not in session:
        return redirect(url_for("login"))
    return render_template('screen7.html')

@app.route('/plan_trip', methods=['GET', 'POST'])
def plan_trip():
    if "user_id" not in session:
        return redirect(url_for("login"))

    if request.method == "POST":
        destination = request.form["destination"]
        start_date = request.form["start_date"]
        end_date = request.form["end_date"]

        cursor.execute(
            "INSERT INTO trips (user_id, destination, start_date, end_date) VALUES (%s, %s, %s, %s)",
            (session.get("user_id"), destination, start_date, end_date)
        )
        mydb.commit()

        flash("Trip planned successfully!", "success")
        return redirect(url_for("next_page"))

    return render_template('screen4.html')

@app.route('/screen5')
def next_page():
    return render_template('screen5.html')

@app.route('/screen6')
def screen6():
    if "user_id" not in session:
        return redirect(url_for("login"))
    return render_template('screen6.html')

@app.route('/jaipur', methods=['GET', 'POST'])
def jaipur():
    return render_template('jaipur.html')

@app.route('/shimla')
def shimla():
    return render_template('shimla.html')

@app.route('/screen8')
def screen8():
    return render_template('screen8.html')

@app.route('/calendar')
def calendar():
    return render_template('screen11.html')

@app.route('/community')
def community():
    return render_template('screen10.html')

@app.route('/save_itinerary', methods=['POST'])
def save_itinerary():
    return render_template('screen6.html')

if __name__ == '__main__':
    app.run(debug=True)