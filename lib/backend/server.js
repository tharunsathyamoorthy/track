require("dotenv").config();
const express = require("express");
const connectDB = require("./config/db");
const billingRoutes = require("./routes/billingRoutes");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
const PORT = process.env.PORT || 5000;

// ✅ Connect to MongoDB
connectDB();

// ✅ Middleware
app.use(cors());
app.use(bodyParser.json());

// ✅ Fix: Ensure correct route prefix
app.use("/api/billing", billingRoutes);

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
