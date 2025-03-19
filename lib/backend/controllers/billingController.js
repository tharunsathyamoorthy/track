const express = require("express");
const router = express.Router();
const Billing = require("../models/Billing");

// ✅ Save Billing Data
router.post("/", async (req, res) => {
  try {
    console.log("📩 Received Billing Data:", req.body);

    if (!req.body.customerName || !req.body.amount || !req.body.date) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const newBilling = new Billing({
      customerName: req.body.customerName,
      amount: req.body.amount,
      notes: req.body.notes || "",
      type: req.body.type || "default",
      repeat: req.body.repeat || false,
      date: req.body.date,
      time: req.body.time || "",
    });

    const savedBill = await newBilling.save();
    console.log("✅ Billing data saved successfully:", savedBill);
    res.status(201).json({ message: "Billing data saved successfully" });

  } catch (error) {
    console.error("❌ Error saving bill:", error.message);
    res.status(500).json({ error: `Failed to save bill: ${error.message}` });
  }
});

// ✅ Fetch Billing History
router.get("/billing-history", async (req, res) => {
  try {
    const history = await Billing.find({});
    res.status(200).json(history);
  } catch (error) {
    console.error("❌ Error fetching billing history:", error.message);
    res.status(500).json({ error: `Failed to fetch billing history: ${error.message}` });
  }
});

// ✅ Delete a Bill
router.delete("/delete-bill/:id", async (req, res) => {
  try {
    const deletedBill = await Billing.findByIdAndDelete(req.params.id);
    if (!deletedBill) {
      return res.status(404).json({ error: "Bill not found" });
    }
    res.status(200).json({ message: "Bill deleted successfully" });
  } catch (error) {
    console.error("❌ Error deleting bill:", error.message);
    res.status(500).json({ error: `Failed to delete bill: ${error.message}` });
  }
});

module.exports = router;
