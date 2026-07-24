"use client";

import { useParams } from "next/navigation";
import { CardDetailPage } from "../../pages";

export default function Page() {
  const params = useParams();
  return <CardDetailPage cardId={params.id as string} />;
}
