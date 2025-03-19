const express = require("express");
const router = express.Router();
const Billing = require("../models/Billing");

// ✅ Save Billing Data
router.post("/", async (req, res) => {
  try {
    console.log("Received Billing Data:", req.body);

    // ✅ Fix: Ensure all fields are correctly assigned
    const newBilling = new Billing({
      customerName: req.body.customerName,
      amount: req.body.amount,
      notes: req.body.notes,
      type: req.body.type,
      repeat: req.body.repeat,
      date: req.body.date,
      time: req.body.time,
    });

    const savedBilling = await newBilling.save();
    res.status(201).json({ message: "Billing data saved successfully", savedBilling });
  } catch (error) {
    console.error("❌ Error saving bill:", error);
    res.status(500).json({ error: "Failed to save bill", details: error.message });
  }
});

// ✅ Fetch Billing History
router.get("/billing-history", async (req, res) => {
  try {
    const history = await Billing.find({});
    res.status(200).json(history);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch billing history", details: error.message });
  }
});

// ✅ Delete a Bill
router.delete("/delete-bill/:id", async (req, res) => {
  try {
    await Billing.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: "Bill deleted successfully" });
  } catch (error) {
    res.status(500).json({ error: "Failed to delete bill", details: error.message });
  }
});

module.exports = router;
