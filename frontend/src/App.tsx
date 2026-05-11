import React from "react";
import { Routes, Route } from "react-router-dom";
import { Toaster } from "@/components/ui/toaster";

import { WalletProvider } from "@/lib/walletContext";
import Header from "@/components/Header";
import Index from "@/pages/Index";
import DashboardPage from "@/pages/DashboardPage";
import PayPage from "@/pages/PayPage";
import NotFound from "@/pages/NotFound";

const App: React.FC = () => {
  return (
    <WalletProvider>
      <div className="min-h-screen bg-background beam-grid scanlines relative">
        <Header />
        <Routes>
          <Route path="/" element={<Index />} />
          <Route path="/dashboard" element={<DashboardPage />} />
          <Route path="/pay/:id" element={<PayPage />} />
          {/* Legacy alias retained for compatibility with old escrow links */}
          <Route path="/escrow/:id" element={<PayPage />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </div>
      <Toaster />
    </WalletProvider>
  );
};

export default App;
