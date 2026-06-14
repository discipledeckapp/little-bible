import Link from 'next/link';

export interface Crumb {
  label: string;
  href?: string;
}

interface Props {
  crumbs: Crumb[];
}

export default function BreadcrumbBar({ crumbs }: Props) {
  return (
    <nav
      className="bg-amber-50/80 border-b border-amber-100 py-2 px-4"
      aria-label="Breadcrumb"
    >
      <ol
        className="max-w-5xl mx-auto flex items-center gap-1 text-xs font-semibold text-amber-700 flex-wrap"
        itemScope
        itemType="https://schema.org/BreadcrumbList"
      >
        <li itemProp="itemListElement" itemScope itemType="https://schema.org/ListItem">
          <Link
            href="/#library"
            className="flex items-center gap-1 hover:text-amber-900 transition-colors"
            itemProp="item"
          >
            <span aria-hidden="true">📖</span>
            <span itemProp="name">Bible Library</span>
          </Link>
          <meta itemProp="position" content="1" />
        </li>

        {crumbs.map((crumb, i) => (
          <li
            key={crumb.label}
            className="flex items-center gap-1"
            itemProp="itemListElement"
            itemScope
            itemType="https://schema.org/ListItem"
          >
            <span className="text-amber-300 select-none" aria-hidden="true">›</span>
            {crumb.href ? (
              <Link
                href={crumb.href}
                className="hover:text-amber-900 transition-colors"
                itemProp="item"
              >
                <span itemProp="name">{crumb.label}</span>
              </Link>
            ) : (
              <span className="text-amber-900 font-bold" itemProp="name" aria-current="page">
                {crumb.label}
              </span>
            )}
            <meta itemProp="position" content={String(i + 2)} />
          </li>
        ))}
      </ol>
    </nav>
  );
}
