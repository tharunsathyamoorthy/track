const mongoose = require("mongoose");

const BillingSchema = new mongoose.Schema({
  customerName: { type: String, required: true },
  amount: { type: Number, required: true },
  notes: { type: String },
  type: { type: String, default: "Other" },
  repeat: { type: String, default: "None" },
  date: { type: String, required: true },
  time: { type: String, required: true },
});

module.exports = mongoose.model("Billing", BillingSchema);
