const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

// PostgreSQL connection. All credentials come from the environment.
// Never commit real credentials to source control.
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'fitlyfe',
});

// Health check for Kubernetes liveness/readiness probes.
app.get('/healthz', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    return res.status(200).json({ status: 'ok' });
  } catch (err) {
    console.error('healthz: database unreachable:', err.message);
    return res.status(503).json({ status: 'degraded' });
  }
});

// POST endpoint to receive feedback
app.post('/api/feedback', async (req, res) => {
  const { feedbackText } = req.body;

  if (!feedbackText || feedbackText.trim() === '') {
    return res.status(400).json({ error: 'Feedback text is required.' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO app_feedback (feedback_text) VALUES ($1) RETURNING id;',
      [feedbackText]
    );

    return res.status(201).json({
      message: 'Feedback submitted successfully',
      id: result.rows[0].id,
    });
  } catch (err) {
    console.error('Database insertion error:', err);
    return res.status(500).json({ error: 'Failed to save feedback to the database.' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Feedback API server running on port ${PORT}`);
});
