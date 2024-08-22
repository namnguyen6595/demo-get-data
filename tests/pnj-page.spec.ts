import {BrowserContext, chromium, Page, test} from "@playwright/test";
import {Parser} from "@json2csv/plainjs";
import {readFile, writeFile} from "fs/promises";
import {format} from "date-fns";

const response: {
	id: string,
	title: string,
	price: string,
	thumbnail: string,
	url: string,
	[key: string]: string
}[] = []
test.describe("Open page", async () => {
	test.beforeAll(async () => {})

	const url  = `https://www.pnj.com.vn/qua-tang/qua-tang-nguoi-than/cho-be/`
	test("", async() => {
		const browser = await chromium.launch();
		const context = await browser.newContext();
		const page = await context.newPage()
		const dataFile = await readFile(
			require.resolve("../data/pnj.json"),
			"utf-8"
		);
		const dataCsv = JSON.parse(dataFile);
		await page.setExtraHTTPHeaders({
			"User-Agent":
				"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",
			"Accept-Language": "en-US,en;q=0.9",
		});
		await page.goto(url)

		let isContinue = true
		while (isContinue) {
			await page.waitForTimeout(3000)
			const infoProducts = page.locator("//div[contains(@class, 'product-item')]")
			const totalProductPages = await infoProducts.count()
			for (let i=0; i< totalProductPages; i++) {
				const productUrl = await infoProducts.nth(i).locator('//div[@class="product-image"]//a').getAttribute("href")
				const productTitle = await infoProducts.nth(i).locator('//div[@class="product-container"]//a').first().textContent()
				const productPrice = await infoProducts.nth(i).locator('//div[@class="product-container"]//span[@class="ty-price-num"]').first().textContent()
				const productThumbnail = await infoProducts.nth(i).locator('//div[@class="product-image"]//a//img').getAttribute("src")
				const id = await infoProducts.nth(i).getAttribute("data-key")
				const result = await openDetailProduct(context, productUrl)
				const data = {
					id,
					title: productTitle,
					price: String(productPrice),
					thumbnail: productThumbnail,
					url: productUrl,
				}
				result.img_url.forEach((item: string, index: number) => {
					data[`image_${index + 1}`] = item
				})
				response.push(data)
			}
			// isContinue = false
			const isLastPage = await page.locator('//a[contains(@class, "ty-pagination__last")]').isVisible()
			if (isLastPage) {
				isContinue = false
				break
			}
			const pathNextPage = '//div[@class="ty-pagination"]//a[contains(@class, "ty-pagination__next")]'
			const nextPage = await page.locator(pathNextPage).isVisible()
			await page.locator(pathNextPage).click()
		}
		await writeFile(
			require.resolve("../data/pnj.json"),
			JSON.stringify(response)
		);
		const fileName = 'pnj' + '_' + format(new Date(), "dd_MM_yyyy");
		await writeFile(__dirname + `/../data/${fileName}.csv`, "");
		try {
			const opts = {}
			const parser = new Parser(opts)
			const csv = parser.parse(dataCsv)
			await writeFile(require.resolve(`../data/${fileName}.csv`), csv)
		} catch (e) {
		}
	})
})

const openDetailProduct = async (context: BrowserContext, url: string) => {
	const page = await context.newPage()
	await page.goto(url)
	const imgUrl: string[] = []
	const imgPath = page.locator('//div[contains(@class, "swiper-container-vertical")]//div[contains(@class, "swiper-slide")]//img')
	await page.waitForTimeout(1500)
	const total = await imgPath.count()
	for (let i = 0; i < total; i++) {
		const url = await imgPath.nth(i).getAttribute("src")
		imgUrl.push(url)
	}
	await page.close()
	return {
		img_url: imgUrl
	}
}