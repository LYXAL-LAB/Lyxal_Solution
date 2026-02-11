import { Box, type BoxProps, type MantineColor, type MantineSize } from "@mantine/core";
import clsx from "clsx";
import { type HTMLAttributes, useMemo } from "react";
import { getIconSize, themeColor } from "~/util/mantine";
import classes from "./style.module.scss";

export interface IconProps
	extends Omit<BoxProps, "left" | "right">,
		Omit<HTMLAttributes<SVGElement>, "style"> {
	size?: MantineSize | number;
	color?: MantineColor;
	left?: boolean;
	right?: boolean;
	noStroke?: boolean;
	stroked?: boolean;
	strokeWidth?: number;
	spin?: boolean;
	path: string;
	flip?: "horizontal" | "vertical";
}

export const Icon = ({
	size,
	color,
	spin,
	path,
	style,
	left,
	right,
	noStroke,
	stroked,
	strokeWidth,
	flip,
	...rest
}: IconProps): JSX.Element | null => {
	const svgStyle = useMemo(() => {
		const rawSize = getIconSize(size);
		const iconSize = rawSize * 1.5;
		const isEm = rawSize <= 2;
		const iconStyle = style || {};

		const styleMarginRight = "marginRight" in iconStyle ? iconStyle.marginRight : undefined;
		const styleMarginLeft = "marginLeft" in iconStyle ? iconStyle.marginLeft : undefined;
		const styleTransform = "transform" in iconStyle ? iconStyle.transform : undefined;

		return Object.assign({}, iconStyle, {
			color: color ? themeColor(color) : undefined,
			width: isEm ? `${iconSize}em` : `${iconSize}px`,
			height: isEm ? `${iconSize}em` : `${iconSize}px`,
			verticalAlign: "middle",
			marginRight: left ? "0.5em" : styleMarginRight,
			marginLeft: right ? "0.5em" : styleMarginLeft,
			flexShrink: 0,
			transform:
				flip === "horizontal"
					? "scaleX(-1)"
					: flip === "vertical"
						? "scaleY(-1)"
						: styleTransform,
		});
	}, [color, left, right, size, style, flip]);

	return (
		<Box
			component="svg"
			viewBox="0 0 24 24"
			role="presentation"
			className={clsx(spin && classes.spinning)}
			style={{ ...svgStyle, overflow: 'visible' }}
			{...rest}
		>
			<path
				d={path}
				style={{
					fill: stroked ? "none" : "currentColor",
					stroke: "currentColor",
					strokeWidth: strokeWidth ?? (stroked ? 1.5 : (noStroke ? 0 : 0.5)),
					strokeLinecap: "round",
					strokeLinejoin: "round"
				}}
			/>
		</Box>
	);
};
