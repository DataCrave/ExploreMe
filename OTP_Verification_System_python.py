import random  # Importing the random module for generating OTP
import tkinter as tk  # Importing the tkinter module as tk for GUI
from tkinter import messagebox  # Importing the messagebox submodule from tkinter

def generate_otp():
    return random.randint(100000, 999999)  # Generating a random OTP between 100000 and 999999

def send_otp_via_email(otp, email):
    print(f"Sending OTP {otp} to email address {email}")  # Printing the OTP being sent to the provided email

class OTPVerificationApp:
    def __init__(self, root):
        self.root = root
        self.root.title("OTP Verification System")  # Setting the title of the GUI window

        self.otp = generate_otp()  # Generating an OTP
        self.email = "abcd@gmail.com"  # Setting a sample email address
        send_otp_via_email(self.otp, self.email)  # Sending the generated OTP to the email
        self.max_attempts = 3  # Setting the maximum number of OTP verification attempts
        self.attempts = 0  # Initializing the attempts counter

        self.label = tk.Label(root, text="Enter the OTP sent to your email:")  # Creating a label for OTP entry
        self.label.pack(pady=10)  # Displaying the label on the GUI

        self.otp_entry = tk.Entry(root)  # Creating an entry field for OTP input
        self.otp_entry.pack(pady=10)  # Displaying the entry field on the GUI

        self.verify_button = tk.Button(root, text="Verify OTP", command=self.verify_otp)  # Creating a button to verify OTP
        self.verify_button.pack(pady=10)  # Displaying the verification button on the GUI

    def verify_otp(self):
        entered_otp = self.otp_entry.get()  # Getting the entered OTP from the entry field
        if entered_otp.isdigit() and int(entered_otp) == self.otp:  # Checking if the entered OTP is valid
            messagebox.showinfo("Success", "Access granted.")  # Showing a success message if OTP is correct
            self.root.destroy()  # Closing the GUI window
        else:
            self.attempts += 1  # Incrementing the attempts counter
            remaining_attempts = self.max_attempts - self.attempts  # Calculating remaining attempts
            if remaining_attempts > 0:
                messagebox.showerror("Error", f"Incorrect OTP. You have {remaining_attempts} attempt(s) left.")
                # Showing error message for incorrect OTP
            else:
                messagebox.showerror("Error", "No more Attempts \n Access denied.")  # Showing access denied message
                self.root.destroy()  # Closing the GUI window


if __name__ == "__main__":
    root = tk.Tk()  # Creating the main GUI window
    app = OTPVerificationApp(root)  # Initializing the OTP verification app
    root.mainloop()  # Running the main event loop
