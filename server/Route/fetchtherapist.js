
const express = require('express');
const router = express.Router();
const db = require('../DB/connection');

// Route to fetch confirmed appointments
router.get('/confirmed-appointments', async (req, res) => {
	try {
		const query = `SELECT app_id, user_id, date, time, status FROM appointment WHERE status = 'confirmed'`;
		db.query(query, (err, results) => {
			if (err) {
				console.error('Error fetching confirmed appointments:', err);
				return res.status(500).json({ error: 'Database error' });
			}
			res.json(results);
		});
	} catch (error) {
		console.error('Server error:', error);
		res.status(500).json({ error: 'Server error' });
	}
});

module.exports = router;
