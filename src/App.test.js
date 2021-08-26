import { render, screen } from '@testing-library/react';
import App from './App';

test('renders learn react link', () => {
  render(<App />);
  const linkElement = screen.getByText(/Ethereum Fullstack Template/i);
  expect(linkElement).toBeInTheDocument();
});
